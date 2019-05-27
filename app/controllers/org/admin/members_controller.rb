class Org::Admin::MembersController < Org::Admin::BaseController
  before_action :set_member, only: [:show, :edit, :update, :token, :destroy]

  def index
    q_params = {
      enabled: true,
    }
    q_params.merge! 'member_departments.organ_id': current_organ.self_and_descendant_ids if current_organ
    q_params.merge! params.permit(:id, 'member_departments.organ_id', 'name-like', :enabled, :department_ancestors)
    #department = Department.find_by id: Member.new(q_params).department_ancestors&.values.to_a.compact.last
    #q_params.merge! department_id: department.self_and_descendant_ids if department
    @members = Member.includes(:roles, member_departments: [:job_title, :department, :organ]).default_where(q_params).order(id: :desc).page(params[:page])
  end

  def leaders
    if params[:q].present?
      @members = Member.default_where('name-like': params[:q])
    elsif params[:department_ids].present?
      department_id = params[:department_ids].split(',')[-2]
      @members = Member.where(department_id: department_id)
    else
      @members = Member.none
    end

    results = []
    @members.each do |member|
      results << { name: member.name, id: member.id }
    end
    render json: { results: results }
  end

  def new
    @member = Member.new
    @member.member_departments.build(organ_id: current_organ.id)
    prepare_form

    respond_to do |format|
      format.js
      format.html
    end
  end

  def create
    @member = Member.find_or_initialize_by(identity: member_params[:identity])
    @member.assign_attribute member_params
    
    respond_to do |format|
      if @member.save
        format.html { redirect_to admin_members_url }
        format.js
      else
        format.html { redirect_to admin_members_url, alert: @member.errors }
        format.js {
          @member.member_departments.build
          prepare_form
          render :new
        }
      end
    end
  end

  def options
    @member_department = @member.member_departments.build
  
    department = Department.find params[:department_id]
    q = {}
    q.merge! office_id: department.office_id if department.office
    @offices = current_organ.offices.default_where(q)
    @job_titles = JobTitle.where(department_id: department.self_and_descendant_ids)
  end

  def show
  end

  def profile
  end

  def edit
    if @member.member_departments.count == 0
      @member.member_departments.build
    end
    prepare_form
  end

  def update
    @member.assign_attributes(member_params)

    respond_to do |format|
      if @member.save
        format.html { redirect_to admin_members_url }
        format.js { redirect_to admin_members_url }
      else
        format.html { render :edit }
        format.js { redirect_to admin_members_url }
      end
    end
  end

  def add_item
    @member = Member.new
    @member.member_departments.build
  end

  def remove_item

  end

  def token
    @member.refresh_organ_token
    redirect_back fallback_location: admin_members_url
  end

  def destroy
    @member.destroy
    respond_to do |format|
      format.html { redirect_to admin_members_url }
      format.js { redirect_to admin_members_url }
      format.json { redirect_to admin_members_url }
    end
  end

  private
  def set_member
    @member = Member.find(params[:id])
  end
  
  def prepare_form
    q_params = { organ_id: current_organ.id }
    if params[:department_id]
      department = Department.find params[:department_id]
      q_params.merge! department_id: department.self_and_descendant_ids
    end
    @job_titles = JobTitle.default_where(q_params)
  end

  def member_params
    params.fetch(:member, {}).permit(
      :name,
      :identity,
      :type,
      :join_on,
      :enabled,
      :avatar,
      :resume,
      role_ids: [],
      member_departments_attributes: {}
    )
  end

end
