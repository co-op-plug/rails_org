class Org::Admin::OrgansController < Org::Admin::BaseController
  before_action :set_organ, only: [:edit, :update, :mock, :destroy]
  
  def index
    q_params = {}
    if current_organ
      q_params.merge! parent_id: current_organ.id
    else
      q_params.merge! parent_id: nil
    end
    
    @organs = Organ.default_where(q_params, parent_id: { allow: nil }).order(id: :desc).page(params[:page])
  end
  
  def show
  end

  def new
    @organ = Organ.new
  end
  
  def create
    if organ_params.select(&->(k, v){ k.start_with?('parent_ancestors') && v.present? }).values.blank?
      @organ = Organ.new organ_params.merge!(parent_id: current_organ.id)
    else
      @organ = Organ.new(organ_params)
    end
  
    if @organ.save
      render 'create'
    else
      render :new
    end
  end

  def edit
  end

  def update
    @organ.assign_attributes(organ_params)

    if @organ.save
      render 'update'
    else
      render :edit
    end
  end
  
  def mock
    organ_grant = @organ.get_organ_grant(current_member || current_user)
    login_organ_as(organ_grant)
    
    redirect_to panel_organ_url
  end

  def destroy
    @organ.destroy
    redirect_to admin_organs_url
  end

  private
  def set_organ
    @organ = Organ.find params[:id]
  end

  def organ_params
    params.fetch(:organ, {}).permit(
      :name,
      :logo,
      :name_short,
      :parent_ancestors,
      :area_ancestors
    )
  end

  def organ_limit_params
    params.fetch(:organ, {}).permit(
      :limit_office,
      :limit_wechat
    )
  end

end
