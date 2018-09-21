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
    setup_ss_vars
    
    #@ss_id = @ss.id
    
    
    #@school = @student.school
    
    #@seminar_id = @seminar.id
    #@term = @seminar.term_for_seminar
    #@oss = @seminar.objective_seminars.includes(:objective).order(:priority)
    #@bucks_current = @student.bucks_current(:seminar, @seminar)
    #@school_or_seminar = "seminar"
    
    #@this_checkpoint = @seminar.which_checkpoint
    #@gs = @student.goal_students.find_by(:seminar => @seminar, :term => @term)
    
    #@objectives = @seminar.objectives.order(:name)
    #objective_ids = @objectives.map(&:id)
    #@student_scores = @student.objective_students.where(:objective_id => objective_ids)
    
    #@quiz_stars_this_term = @student.quiz_stars_this_term(@seminar)
    #@stars_used_toward_grade_this_term = @student.stars_used_toward_grade_this_term(@seminar, @seminar.term_for_seminar)
    #@total_stars_this_term = @quiz_stars_this_term + @stars_used_toward_grade_this_term
    #@quiz_stars_all_time = @student.quiz_stars_all_time(@seminar)
    
    #@teach_options = @student.teach_options(@seminar, @seminar.rank_objectives_by_need)
    #@learn_options = @student.learn_options(@seminar, @seminar.rank_objectives_by_need)
  
    update_current_class
  end
  
  def update
    @ss = SeminarStudent.find(params[:id])
    if params[:bucks_to_add]
      Currency.create(:seminar => @ss.seminar, :user => @ss.user, :giver => current_user, :value => params[:bucks_to_add])
    elsif params[:present]
      @ss.update(:present => params[:present])
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
  
  
  ## Views for submenus
  
  def give_keys
    setup_ss_vars
    
    @objectives = @seminar.objectives.order(:name)
  end
  
  def move_or_remove
    setup_ss_vars
    
    @new_ss = SeminarStudent.new
    @classes_without_student_list = current_user.seminars.select{|x| !x.students.include?(@student) }
    @classes_with_student_list = current_user.seminars.select{|x| x.students.include?(@student) }
  end
  
  def star_market
    setup_ss_vars
    
    @bucks_current = @student.bucks_current(:seminar, @seminar)
    @dbi = @seminar.default_buck_increment
    @commodities = @seminar.commodities_for_seminar.paginate(:per_page => 6, page: params[:page])
    @term = @seminar.term_for_seminar
    @school_or_seminar = "seminar"
  end
  
  def quizzes
    setup_ss_vars
    
    @unfinished_quizzes = @student.all_unfinished_quizzes(@seminar)
    @desk_consulted_objectives = @student.quiz_collection(@seminar, "dc")
    @pretest_objectives = @student.quiz_collection(@seminar, "pretest")
    @teacher_granted_quizzes = @student.quiz_collection(@seminar, "teacher_granted")
    
    @show_quizzes = @desk_consulted_objectives.present? || @pretest_objectives.present? || @unfinished_quizzes.present? || @teacher_granted_quizzes.present?
  end

  private
      def ss_params
        params.require(:seminar_student).permit(:seminar_id, :user_id, :teach_request, 
                                  :learn_request, :pref_request, :present)
      end
      
      def correct_ss_user
        @ss = SeminarStudent.find(params[:id])
        @seminar = Seminar.find(@ss.seminar_id)
        redirect_to login_url unless (current_user && (@ss.user == current_user || current_user.seminars.include?(@seminar))) || user_is_an_admin
      end
      
      def setup_ss_vars
        @ss = SeminarStudent.find(params[:id])
        @ss_id = @ss.id
        @student = @ss.user
        @seminar = @ss.seminar
        @teachers = @seminar.teachers
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
