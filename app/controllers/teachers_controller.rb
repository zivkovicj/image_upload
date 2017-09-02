class TeachersController < ApplicationController

  before_action :correct_user, only: [:show, :edit, :update, :destroy]
  before_action :redirect_for_non_admin, only: [:index]
  
  
  def new
    @teacher = Teacher.new
  end
  
  def create
    @teacher = Teacher.new(teacher_params)
    if @teacher.save
      #@teacher.send_activation_email
      log_in @teacher
      flash[:success] = "Welcome to Mr.Z School!"
      redirect_to @teacher
    else
      render 'new'
    end
  end
  
  def show
    @teacher = Teacher.find(params[:id])
    @own_seminars = @teacher.own_seminars
    current_user.update(:current_class => nil)
  end
  
  def index
    @teachers = (params[:search].blank? ? Teacher.paginate(page: params[:page]) : Teacher.paginate(page: params[:page]).search(params[:search], params[:whichParam]))
  end
  
  def edit
    @teacher = Teacher.find(params[:id])
  end
  
  def update
    @teacher = Teacher.find(params[:id])
    if @teacher.update_attributes(teacher_params)
      flash[:success] = "Profile updated" 
      redirect_to current_user
    else
      render 'edit'
    end
  end
  
  def destroy
    @teacher = Teacher.find(params[:id])
    if @teacher.destroy
      flash[:success] = "Teacher deleted"
      redirect_to teachers_path
    end
  end
  
  private
  
    def teacher_params
      params.require(:teacher).permit(:first_name, :last_name, :title, :email, :password, 
                                :password_confirmation, :current_class, :user_number)
    end

end