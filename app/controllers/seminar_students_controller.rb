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
  
  def show
    @ss = SeminarStudent.find(params[:id])
    @student = @ss.user
    @seminar = @ss.seminar
    @oss = @seminar.objective_seminars.includes(:objective).order(:priority)
    
    @this_checkpoint = @seminar.which_checkpoint
    @this_gs = @student.goal_students.find_by(:seminar => @seminar, :term => @seminar.term)
    
    @objectives = @seminar.objectives.order(:name)
    objective_ids = @objectives.map(&:id)
    @student_scores = @student.objective_students.where(:objective_id => objective_ids)
    
    @total_stars = @student.total_stars(@seminar)
    @teacher = @seminar.user
    
    @teach_options = @student.teach_options(@seminar, @seminar.rank_objectives_by_need)
    @learn_options = @student.learn_options(@seminar, @seminar.rank_objectives_by_need)
    
    @unfinished_quizzes = @student.all_unfinished_quizzes(@seminar)
    @desk_consulted_objectives = @student.desk_consulted_objectives(@seminar)
    @all_pretest_objectives = @seminar.all_pretest_objectives(@student)
    
    @show_quizzes = @desk_consulted_objectives.present? || @all_pretest_objectives.present? || @unfinished_quizzes.present?
    
    update_current_class
  end
  
  def update
    @ss = SeminarStudent.find(params[:id])
    @ss.update_attributes(ss_params)
    respond_with @ss
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
        @ss = SeminarStudent.find(params[:id])
        @seminar = Seminar.find(@ss.seminar_id)
        redirect_to login_url unless (current_user && (@ss.user == current_user || current_user.own_seminars.include?(@seminar))) || user_is_an_admin
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
