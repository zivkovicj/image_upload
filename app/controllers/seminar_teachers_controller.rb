class SeminarTeachersController < ApplicationController
  respond_to :html, :json
  
  def new
    @seminar = Seminar.find(params[:seminar_id])
    @user = Teacher.find(params[:user_id])
    @st = SeminarTeacher.create(:seminar => @seminar, :user => @user)
    flash[:success] = "#{@user.full_name_with_title} Invited"
    redirect_to shared_teachers_seminar_path(@seminar)
  end
  
  def update
    @seminar_teacher = SeminarTeacher.find(params[:id])
    if @seminar_teacher.update_attributes(seminar_teacher_params)
      flash[:success] = "Access Updated"
      if params[:came_from_accepting_invites]
        home_or_more_invites
      else
        redirect_to shared_teachers_seminar_path(@seminar_teacher.seminar)
      end
    end
  end
  
  def destroy
    @seminar_teacher = SeminarTeacher.find(params[:id])
    if @seminar_teacher.destroy
      some_user_can_edit
      flash[:success] = "Invitation Declined"
      home_or_more_invites
    end
  end
  
  def accept_invitations
    @unaccepted_classes = current_user.unaccepted_classes
  end
  
  private
  
    def seminar_teacher_params
      params.require(:seminar_teacher).permit(:can_edit, :accepted)
    end
    
    def home_or_more_invites
      if current_user.unaccepted_classes.count > 0
        redirect_to accept_invitations_seminar_teachers_path
      else
        redirect_to current_user
      end
    end
    
    def some_user_can_edit
      @seminar = @seminar_teacher.seminar
      if @seminar.seminar_teachers.where(:can_edit => true).count == 0
        @seminar.seminar_teachers.update_all(:can_edit => true)
      end
    end
end
