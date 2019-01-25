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
        where_to_direct
      else
        redirect_to shared_teachers_seminar_path(@seminar_teacher.seminar)
      end
    end
  end
  
  def destroy
    @seminar_teacher = SeminarTeacher.find(params[:id])
    @seminar = @seminar_teacher.seminar
    if @seminar_teacher.destroy
      flash[:success] = "Teacher removed from class"
      where_to_direct
    end
  end
  
  def accept_invitations
    @unaccepted_classes = current_user.unaccepted_classes
  end
  

  
  private
  
    def seminar_teacher_params
      params.require(:seminar_teacher).permit(:can_edit, :accepted)
    end
    
    def where_to_direct
      # If another teacher removed this teacher from the class 
      if params[:other_teacher_removed] == "true" then
        redirect_to @seminar
      else
        # If you removed yourself by declining the invite.
        if current_user.unaccepted_classes.count > 0
          redirect_to accept_invitations_seminar_teachers_path
        else
          redirect_to current_user
        end
      end
    end
end
