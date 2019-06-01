class ObjectiveStudentsController < ApplicationController
  respond_to :html, :json
  before_action :redirect_for_non_admin,    only: [:index, :destroy]
  
  def index
    @o_ss = ObjectiveStudent.paginate(page: params[:page])
  end
  
  def update
    @o_s = ObjectiveStudent.find(params[:id])
    key_type = params[:objective_student][:key_type]
    new_keys = params[:objective_student][:new_keys]
    @o_s.update_keys(key_type, new_keys)
    respond_with @o_s
  end
  
  def destroy
    @o_s = ObjectiveStudent.find(params[:id])
    @o_s.destroy
  end
  
  private
  
    def score_params
      params.require(:objective_student).permit(:user_id, :objective_id)
    end
end


