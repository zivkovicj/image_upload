class StudentsController < ApplicationController
  before_action :correct_student,   only: [:edit, :update]
  before_action :redirect_for_non_admin, only: [:destroy]
  
  include AddStudentStuff
  include TeachAndLearnOptions
  
  
  def new
    new_student_stuff
  end

  def create
    @seminar = Seminar.find(params[:ss][:seminar_id])
    one_saved = false
    params["students"].each do |student|
      if student["first_name"] != "" && student["last_name"] != ""
        @student = Student.new(multi_params(student))
        if @student.save
          one_saved = true
          @ss = @student.seminar_students.create(:seminar => @seminar)
          #addToSeatingChart(@seminar, @student)
          scoresForNewStudent(@seminar, @student)
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
    if !params[:search].blank?
      @students = Student.order(:last_name).paginate(page: params[:page]).search(params[:search], params[:whichParam])
    end
    
    if current_user.type == "Admin"
      @students ||= Student.order(:last_name).paginate(page: params[:page])
    elsif current_user.type == "Student"
      redirect_to login_url
    else
      @students ||= []
      @seminar = Seminar.find(current_user.current_class)
      @ss = SeminarStudent.new
    end
  end

  def edit
    @student = Student.find(params[:id])
    if current_user.type == "Teacher" && current_user.current_class
      @seminar = Seminar.find(current_user.current_class)
      @ss = SeminarStudent.find_by(:user => @student, :seminar => @seminar)
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
    
    @teach_options = teach_options(@student, @seminar, 5)
    @learn_options = learn_options(@student, @seminar, 5)
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
