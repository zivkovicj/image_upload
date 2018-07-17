class TeachersController < ApplicationController

  before_action :correct_user, only: [:show, :edit, :update, :destroy]
  before_action :redirect_for_non_admin, only: [:index]
  
  def new
    @teacher = Teacher.new
  end
  
  def create
    @teacher = Teacher.new(teacher_params)
    if @teacher.save
      @teacher.send_activation_email
      create_star_commodity
      log_in @teacher
      flash[:success] = "Welcome to Mr.Z School!"
      redirect_to new_school_path(:teacher_id => @teacher.id)
    else
      render 'new'
    end
  end
  
  def show
    @teacher = Teacher.find(params[:id])
    @seminars = @teacher.seminars
    current_user.update(:current_class => nil)
    @school = @teacher.school
    check_if_term_needs_updated
    create_commodities
    @unverified_teachers = @school.unverified_teachers if @teacher.school_admin > 0
    @unaccepted_classes = @teacher.unaccepted_classes
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
      if @teacher.school.present?
        flash[:success] = "Profile updated" 
        redirect_to current_user
      end
    else
      render 'edit'
    end
  end
  
  def destroy
    @teacher = Teacher.find(params[:id])
    if @teacher.destroy
      flash[:success] = "Teacher Deleted"
      redirect_to teachers_path
    end
  end
  
  private
    
    ## Always on top method
    def teacher_params
      params.require(:teacher).permit(:first_name, :last_name, :title, :email, :password, 
                                :password_confirmation, :current_class, :user_number, :school_id)
    end
    
    ## Other methods
    def create_star_commodity
      new_star = @teacher.commodities.new
      new_star.name = "Star"
      new_star.quantity = 25
      new_star.current_price = 5
      new_star.date_last_produced = Date.today
      new_star.production_rate = 10
      new_star.production_day = 0
      image_src = File.join(Rails.root, "app/assets/images/stars/filled_star.png")
      src_file = File.new(image_src)
      new_star.image = src_file
      new_star.save
    end
end