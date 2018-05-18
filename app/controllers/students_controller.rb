class StudentsController < ApplicationController
  before_action :correct_student,   only: [:edit, :update]
  before_action :redirect_for_students, only: [:index]
  before_action :redirect_for_non_admin, only: [:destroy]
  
  include AddStudentStuff
  
  def new
    new_student_stuff
  end

  def create
    @seminar = Seminar.find(params[:ss][:seminar_id])
    one_saved = false
    params["students"].each do |student|
      if student["first_name"] != "" && student["last_name"] != ""
        @student = Student.new(multi_params(student))
        sponsor = current_user
        @student.sponsor = sponsor
        @student.school = sponsor.school if sponsor.verified > 0
        if @student.save
          one_saved = true
          @ss = @student.seminar_students.create(:seminar => @seminar)
          #addToSeatingChart(@seminar, @student)
          scores_for_new_student(@seminar, @student)
          pretest_keys_for_new_student(@seminar, @student)
          goals_for_new_student(@seminar, @student)
        end
      end
    end
    
    if one_saved 
      flash[:success] = "Students added to class"
      redirect_to scoresheet_seminar_url(@seminar)
    else
      new_student_stuff
      flash[:danger] = "No students could be created."
      render 'new'
    end
  end
  
  def show
    @student = Student.find(params[:id])
  end
  
  def index
    first_layer = params[:search].present? ? Student.search(params[:search], params[:whichParam]) : Student.none
    
    if first_layer == [0]
      @students = [0]
    else
      if current_user.type == "Admin"
        second_layer = first_layer
      else
        @seminar = Seminar.find(current_user.current_class)
        @ss = SeminarStudent.new
        second_layer = current_user.verified == 1 ? first_layer.where(:school => current_user.school) : first_layer.where(:sponsor => current_user)
      end
    
      @students = second_layer.order(:last_name).paginate(page: params[:page])
    end
  end

  def edit
    @student = Student.find(params[:id])
    if current_user.type == "Teacher" && current_user.current_class
      @seminar = Seminar.find(current_user.current_class)
      @ss = SeminarStudent.find_by(:user => @student, :seminar => @seminar)
      @new_ss = SeminarStudent.new
    end
  end

  def update
    @student = Student.find(params[:id])
    if @student.update_attributes(student_params)
      flash[:success] = "Profile updated"
      if current_user.type == "Teacher" && current_user.current_class
        @seminar = Seminar.find(current_user.current_class)
        redirect_to scoresheet_seminar_url(@seminar)
      else
        redirect_to @student
      end
    else
      render 'edit'
    end
  end

  def edit_teaching_requests
    @student = Student.find(params[:id])
    @seminar = Seminar.includes(:objective_seminars).find(current_user.current_class)
    blap = @seminar.objectives.map(&:id)
    @student_scores = ObjectiveStudent.where(objective_id: blap, :user => @student)
    @oss = @seminar.objective_seminars.includes(:objective).order(:priority)
    @ss = SeminarStudent.find_by(:user => @student, :seminar => @seminar)
    
    @teach_options = @student.teach_options(@seminar, @seminar.rank_objectives_by_need)
    @learn_options = @student.learn_options(@seminar, @seminar.rank_objectives_by_need)
  end

  def destroy
    @student = Student.find(params[:id])
    if @student.destroy
      flash[:success] = "Student Deleted"
      redirect_to students_path
    end
  end


  private
  
    def student_params
      params.require(:student).permit(:first_name, :last_name, :email, :password, :password_confirmation, :username, :user_number)
    end
    
    def multi_params(my_params)
      my_params.permit(:first_name, :last_name, :email, :password, :password_digest, :username, :user_number)
    end
    
    # Confirms the correct student.
    def correct_student
      @student = Student.find(params[:id])
      redirect_to(login_url) unless (@student == current_user || user_is_an_admin || (user_is_a_teacher && current_user.students.include?(@student)))
    end
    
    def new_student_stuff
      @student_group = []
      55.times do
        @student_group << Student.new
      end
    end
end
