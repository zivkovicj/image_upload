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
    @new_ss = SeminarStudent.new
    @student = @ss.user
    @school = @student.school
    @seminar = @ss.seminar
    @term = @seminar.term_for_seminar
    @oss = @seminar.objective_seminars.includes(:objective).order(:priority)
    
    @this_checkpoint = @seminar.which_checkpoint
    @gs = @student.goal_students.find_by(:seminar => @seminar, :term => @term)
    
    @objectives = @seminar.objectives.order(:name)
    objective_ids = @objectives.map(&:id)
    @student_scores = @student.objective_students.where(:objective_id => objective_ids)
    
    @quiz_stars_this_term = @student.quiz_stars_this_term(@seminar, @seminar.term_for_seminar)
    @stars_used_toward_grade_this_term = @student.stars_used_toward_grade_this_term(@seminar, @seminar.term_for_seminar)
    @total_stars_this_term = @quiz_stars_this_term + @stars_used_toward_grade_this_term
    @quiz_stars_all_time = @student.quiz_stars_all_time(@seminar)
    @teachers = @seminar.teachers
    
    @teach_options = @student.teach_options(@seminar, @seminar.rank_objectives_by_need)
    @learn_options = @student.learn_options(@seminar, @seminar.rank_objectives_by_need)
    
    @unfinished_quizzes = @student.all_unfinished_quizzes(@seminar)
    @desk_consulted_objectives = @student.quiz_collection(@seminar, "dc")
    @pretest_objectives = @student.quiz_collection(@seminar, "pretest")
    @teacher_granted_quizzes = @student.quiz_collection(@seminar, "teacher_granted")
    
    @show_quizzes = @desk_consulted_objectives.present? || @pretest_objectives.present? || @unfinished_quizzes.present? || @teacher_granted_quizzes.present?
    
    update_current_class
  end
  
  def update
    @ss = SeminarStudent.find(params[:id])
    @this_com_stud = CommodityStudent.find_by(params[:commodity_student_id]) if params[:commodity_student_id]
    if params[:bucks_to_add]
      @ss.update(:bucks_owned => @ss.bucks_owned + params[:bucks_to_add].to_i)
    elsif params[:use]
      use_commodity
    elsif params[:commodity_student_id]
      buy_commodity
    else
      req_type = params[:seminar_student][:req_type]
      req_id = params[:seminar_student][:req_id]  
      @ss.write_attribute(:"#{req_type}_request", req_id)
      @ss.save
    end
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
      
      def buy_commodity
        multiplier = params[:multiplier].to_i
        commode = @this_com_stud.commodity
        
        buy_allowed = multiplier > 0 && @ss.bucks_owned > 0 && commode.quantity > 0
        sell_allowed = multiplier < 0 && @this_com_stud.quantity > 0
        if buy_allowed || sell_allowed
          @this_com_stud.update(:quantity => @this_com_stud.quantity + multiplier)
          
          cost = (commode.current_price * multiplier)
          @ss.update(:bucks_owned => @ss.bucks_owned - cost)
          commode.update(:quantity => commode.quantity - 1)
        end
      end
      
      def use_commodity
        @this_com_stud.update(:quantity => @this_com_stud.quantity - 1)
        
        term = @ss.seminar.term_for_seminar
        old_stars = @ss.stars_used_toward_grade[term]
        @ss.stars_used_toward_grade[term] = old_stars + 1
        @ss.save
      end
      
      def correct_ss_user
        @ss = SeminarStudent.find(params[:id])
        @seminar = Seminar.find(@ss.seminar_id)
        redirect_to login_url unless (current_user && (@ss.user == current_user || current_user.seminars.include?(@seminar))) || user_is_an_admin
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
