class StudentsController < ApplicationController
  before_action :correct_student,   only: [:edit, :update]
  before_action :admin_or_teacher, only: [:destroy]
  
  include AddStudentStuff
  include RankObjectivesByNeed
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
        if @student.save
          autoInfo(@student)   #autoinfo makes a student_number, username, and password if they're blank
          @ss = @student.seminar_students.create(:seminar => @seminar)
          
          addToSeatingChart(@seminar, @student)
          scoresForNewStudent(@seminar, @student)
        end
      end
    end
    flash[:success] = "Students added to class"
    redirect_to scoresheet_url(@seminar)
  end
  
  def index
    if !params[:search].blank?
      @students = Student.paginate(page: params[:page]).search(params[:search], params[:whichParam])
    end
    
    if current_user.role == "admin"
      @students ||= Student.paginate(page: params[:page])
    elsif current_user.role == "student"
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
      autoInfo(@student)
      flash[:success] = "Profile updated"
      if current_user.role == "teacher" && current_user.current_class
        @seminar = Seminar.find(current_user.current_class)
        redirect_to scoresheet_url(@seminar)
      else
        redirect_to @student
      end
    else
      render 'edit'
    end
  end

  def edit
    @student = Student.find(params[:id])
    if current_user.role == "teacher" && current_user.current_class
      @seminar = Seminar.find(current_user.current_class)
      @ss = SeminarStudent.find_by(:student_id => @student.id, :seminar_id => @seminar.id)
    end
  end
  
  def edit_teaching_requests
    @student = Student.find(params[:id])
    @seminar = Seminar.find(current_user.current_class)
    blap = @seminar.objectives.map(&:id)
    @student_scores = ObjectiveStudent.where(objective_id: blap, student_id: @student.id)
    @ss = SeminarStudent.find_by(:student_id => @student.id, :seminar_id => @seminar.id)
    
    @rankAssignsByNeed = rankAssignsByNeed(@seminar)
    @teachOptions = teachOptions(@student, @rankAssignsByNeed, @seminar.consultantThreshold, 10)
    @learnOptions = learnOptions(@student, @rankAssignsByNeed, 10)
  end

  def destroy
    @student = Student.find(params[:id]).destroy
  end


  private
  
    def student_params
      params.require(:student).permit(:first_name, :last_name, :email,
        :password, :password_confirmation, :username, :student_number)
    end
    
    def multi_params(my_params)
      my_params.permit(:first_name, :last_name, :email,
        :password, :password_confirmation, :username, :student_number)
    end
    
    # Generates a unique username, based on initials and student number
    def makeUsername(student)
        firstInitial = student.first_name[0,1].downcase
        lastInitial = student.last_name[0,1].downcase
        student_number = student.student_number
        username = "#{firstInitial}#{lastInitial}#{student_number}"
        if Student.find_by(:username => username) == nil
            return username
        else
            firstDown = student.first_name.downcase
            username = "#{firstDown}#{lastInitial}#{student_number}"
            if Student.find_by(:username => username) == nil
                return username
            else
                lastDown = student.last_name.downcase
                username = "#{firstInitial}#{lastDown}#{student_number}"
                if Student.find_by(:username => username) == nil
                    return username
                else
                    username = "#{firstDown}#{lastDown}#{student_number}"
                    if Student.find_by(:username => username) == nil
                        return username
                    else
                        flash[:notice] = "Could not generate an automatic username
                            for this student. You will need to create a username
                            if you want this student to be able to log in."
                        return nil
                    end
                end
            end
        end
    end
    
    def autoInfo(student)   # Auto-generate missing info for students
      @student.role = "student"
      updated = false
      
      if student.student_number.blank?
        student.student_number = student.id
        updated = true
      end
      
      if student.username.blank?
        student.username = makeUsername(student)
        updated = true
      end
      
      if student.password.blank?
        student.password = "#{student.student_number}"
        updated = true
      end
      
      student.save! if updated
    end

    # Confirms the correct student.
    def correct_student
      @student = Student.find(params[:id])
      redirect_to(login_url) unless (session[:user_id] == @student.id || (current_user && current_user.role == "teacher" && current_user.students.include?(@student)))
    end
    
    def admin_or_teacher
      @student = Student.find(params[:id])
      redirect_to(root_url) unless (current_user.role == "teacher" && current_user.students.include?(@student)) || current_user.role == "admin"
    end
end
