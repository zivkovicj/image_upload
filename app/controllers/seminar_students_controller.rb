class SeminarStudentsController < ApplicationController
  respond_to :html, :json
  before_action :correct_ss_user, only: [:destroy, :show, :edit]
  
  include AddStudentStuff


  def update
    @ss = SeminarStudent.find(params[:id])
    @ss.update_attributes(ss_params)
    @seminar = Seminar.find(@ss.seminar_id)
    if (params[:ss][:teach_request])
      if current_user.type == "Teacher"
        flash[:success] = "Student request updated"
        redirect_to scoresheet_seminar_url(@seminar)
      else
        flash[:success] = "Your requests were updated"
        redirect_to student_view_seminar_path(@seminar)
      end
    else
      respond_with @ss
    end
  end
  

  
  def create
    # This method is called when the teacher adds an existing student to a class.
    # It is not called when creating a new student.
    @ss = SeminarStudent.create(ss_params)
    @seminar = Seminar.find(@ss.seminar_id)
    @student = Student.find(@ss.student_id)
    
    addToSeatingChart(@seminar, @student)
    scoresForNewStudent(@seminar, @student)
    
    redirect_to scoresheet_seminar_url(@seminar)
  end
  
  def ajaxUpdate
    @ss = SeminarStudent.find(params[:id])
    @ss.update_attributes(ss_params)
    respond_with @ss
  end
  
  def destroy
    this_ss = SeminarStudent.find(params[:id])
    @seminar = Seminar.find(this_ss.seminar_id)
    
    #Remove student from seating chart
    #@seminar.seating.delete(thisSeminarStudent.student_id)
    #@seminar.save
    
    this_ss.destroy
    
    #Redirect
    flash[:success] = "Student removed from class period"
    redirect_to scoresheet_seminar_url(@seminar)
  end

  private
      def ss_params
        params.require(:seminar_student).permit(:seminar_id, :student_id, :teach_request, 
                                  :learn_request, :pref_request, :present)
      end
      
      def correct_ss_user
        @ss = SeminarStudent.find_by(id: params[:id])
        @seminar = Seminar.find(@ss.seminar_id)
        redirect_to login_url unless (current_user && current_user.own_seminars.include?(@seminar)) || user_is_an_admin
      end
end
