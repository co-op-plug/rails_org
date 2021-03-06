class Org::OrgansController < ApplicationController
  before_action :set_organ, only: [:show, :login]
  
  def index
    q_params = { parent_id: nil, allow: { parent_id: nil } }
    @organs = Organ.default_where(q_params).order(id: :desc).page(params[:page])
    
    session.delete :organ_token
  end
  
  def show
  end
  
  def login
    organ_token = @organ.get_organ_grant(current_user)
    login_organ_as organ_token
  
    respond_to do |format|
      format.html { redirect_to my_index_url }
      format.json { render json: { organ_grant: organ_grant } }
    end
  end

  private
  def set_organ
    @organ = Organ.find params[:id]
  end

end
