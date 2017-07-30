class ObjectiveStudentsController < ApplicationController
  respond_to :html, :json
  
  before_action :admin_user,    only: [:index, :destroy]
  
  def index
    @objective_students = ObjectiveStudent.paginate(page: params[:page])
  end
  
  def update
    @objective_student = ObjectiveStudent.find(params[:id])
    @objective_student.update_attributes(score_params)
    respond_with @objective_student
  end
  
  def destroy
    @objective_student = ObjectiveStudent.find(params[:id])
    @objective_student.destroy
  end
  
  private
  
    def score_params
      params.require(:objective_student).permit(:student_id, :objective_id, :points)
    end
end


