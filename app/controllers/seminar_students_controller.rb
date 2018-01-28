class SeminarStudentsController < ApplicationController
  respond_to :html, :json
  before_action :correct_ss_user, only: [:destroy, :show, :edit]
  
  include AddStudentStuff


  def create
    # This method is called when the teacher adds an existing student to a class.
    # Or moves a student to a different class. 
    # It is not called when creating a new student.
    @ss = SeminarStudent.create(ss_params)
    @seminar = Seminar.find(@ss.seminar_id)
    @student = Student.find(@ss.user_id)
    @student.update(:sponsor => current_user) if current_user.type == "Teacher"
    
    addToSeatingChart(@seminar, @student)
    scores_for_new_student(@seminar, @student)
    goals_for_new_student(@seminar, @student)
    
    old_ss_id = params[:seminar_student][:is_move]
    if old_ss_id
      @old_ss = SeminarStudent.find(old_ss_id)
      update_goal_students_for_new_class_to_match_old_class
      @old_ss.destroy
    end
    
    redirect_to scoresheet_seminar_url(@seminar)
  end
  
  def update
    @ss = SeminarStudent.find(params[:id])
    @ss.update_attributes(ss_params)
    respond_with @ss
  end
  
  def update_benchmarks
    seminar_id = params[:seminar]
    params[:set_benchmark].each do |id|
      SeminarStudent.find_by(:user_id => id, :seminar_id => seminar_id).ss_benchmark_stars
    end
    redirect_to scoresheet_seminar_path(seminar_id)
  end
  
  def destroy
    this_ss = SeminarStudent.find(params[:id])
    @seminar = Seminar.find(this_ss.seminar_id)
    
    this_ss.destroy
    
    #Redirect
    flash[:success] = "Student removed from class period"
    redirect_to scoresheet_seminar_url(@seminar)
  end

  private
      def ss_params
        params.require(:seminar_student).permit(:seminar_id, :user_id, :teach_request, 
                                  :learn_request, :pref_request, :present)
      end
      
      def correct_ss_user
        @ss = SeminarStudent.find_by(id: params[:id])
        @seminar = Seminar.find(@ss.seminar_id)
        redirect_to login_url unless (current_user && current_user.own_seminars.include?(@seminar)) || user_is_an_admin
      end
      
      def update_goal_students_for_new_class_to_match_old_class
        @student.goal_students.where(:seminar => @old_ss.seminar).each do |old_gs|
          new_gs = @student.goal_students.find_by(:seminar => @seminar, :term => old_gs.term)
          new_gs.update(:goal => old_gs.goal, :target => old_gs.target, :approved => old_gs.approved)
          old_gs.checkpoints.each do |old_checkpoint|
            new_checkpoint = new_gs.checkpoints.find_by(:sequence => old_checkpoint.sequence)
            new_checkpoint.update(:action => old_checkpoint.action, :achievement => old_checkpoint.achievement, :teacher_comment => old_checkpoint.teacher_comment, 
              :student_comment => old_checkpoint.student_comment)
          end
        end
      end
end
