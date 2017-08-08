class StudentsController < ApplicationController
  before_action :correct_student,   only: [:edit, :update]
  before_action :redirect_for_non_admin, only: [:destroy]
  
  include AddStudentStuff
  include TeachAndLearnOptions
  
  def new
    @student_group = []
    55.times do
      @student_group << Student.new
    end
  end

  def create
    @seminar = Seminar.find(params[:ss][:seminar_id])
    params["students"].each do |student|
      if student["first_name"] != "" && student["last_name"] != ""
        @student = Student.new(multi_params(student))
        @student.password = student["password"] if student["password"]
        if @student.save
          auto_info
          @student.save
          @ss = @student.seminar_students.create(:seminar => @seminar)
          #addToSeatingChart(@seminar, @student)
          scoresForNewStudent(@seminar, @student)
        end
      end
    end
    flash[:success] = "Students added to class"
    redirect_to scoresheet_seminar_url(@seminar)
  end
  
  def index
    if !params[:search].blank?
      @students = Student.paginate(page: params[:page]).search(params[:search], params[:whichParam])
    end
    
    if current_user.type == "Admin"
      @students ||= Student.paginate(page: params[:page])
    elsif current_user.type == "Student"
      redirect_to login_url
    else
      @students ||= []
      @seminar = Seminar.find(current_user.current_class)
      @ss = SeminarStudent.new
    end
  end

  def show
    @student = Student.find(params[:id])
  end

  def update
    @student = Student.find(params[:id])
    if @student.update_attributes(student_params)
      auto_info
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

  def edit
    @student = Student.find(params[:id])
    if current_user.type == "Teacher" && current_user.current_class
      @seminar = Seminar.find(current_user.current_class)
      @ss = SeminarStudent.find_by(:student_id => @student.id, :seminar_id => @seminar.id)
    end
  end
  
  def edit_teaching_requests
    @student = Student.find(params[:id])
    @seminar = Seminar.includes(:objective_seminars).find(current_user.current_class)
    blap = @seminar.objectives.map(&:id)
    @student_scores = ObjectiveStudent.where(objective_id: blap, student_id: @student.id)
    @oss = @seminar.objective_seminars.includes(:objective).order(:priority)
    @ss = SeminarStudent.find_by(:student_id => @student.id, :seminar_id => @seminar.id)
    
    @teach_options = teach_options(@student, @seminar, 5)
    @learn_options = learn_options(@student, @seminar, 5)
  end

  def destroy
    @student = Student.find(params[:id]).destroy
  end


  private
  
    def student_params
      params.require(:student).permit(:first_name, :last_name, :email,
        :password, :password_confirmation, :username, :user_number)
    end
    
    def multi_params(my_params)
      my_params.permit(:first_name, :last_name, :email,
        :password_digest, :username, :user_number)
    end
    
    # Confirms the correct student.
    def correct_student
      @student = Student.find(params[:id])
      redirect_to(login_url) unless (@student == current_user || user_is_an_admin || (user_is_a_teacher && current_user.students.include?(@student)))
    end
    
    def make_username()
      firstInitial = @student.first_name[0,1].downcase
      lastInitial = @student.last_name[0,1].downcase
      user_number = @student.user_number
      @student_number = @student.user_number
      username = "#{firstInitial}#{lastInitial}#{user_number}"
      return username if User.find_by(:username => username) == nil
      
      firstDown = @student.first_name.downcase
      username = "#{firstDown}#{lastInitial}#{user_number}"
      return username if User.find_by(:username => username) == nil

      lastDown = @student.last_name.downcase
      username = "#{firstInitial}#{lastDown}#{user_number}"
      return username if User.find_by(:username => username) == nil

      username = "#{firstDown}#{lastDown}#{user_number}"
      return username if User.find_by(:username => username) == nil

      flash[:notice] = "Could not generate an automatic username
          for #{@student.first_name} #{@student.last_name}, and possibly other users."
      return nil
    end
    
    def auto_info   # Auto-generate missing info for students
      @student.title = "Awesome" if @student.title.blank?
      @student.user_number = @student.id if @student.user_number.blank?
      @student.username = make_username() if @student.username.blank?
      @student.password = "#{@student.user_number}" if @student.password_digest.blank?
    end
end
