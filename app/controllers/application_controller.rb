class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper
  
  # Confirms a logged-in user.
  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end
  
  def user_is_an_admin
    current_user&.type == "Admin"
  end
  
  def redirect_for_non_admin
    redirect_to(login_url) unless user_is_an_admin
  end
  
  def correct_user()
    @user = User.find(params[:id])
    redirect_to(login_url) unless (current_user?(@user) || user_is_an_admin)
  end
  
  def correct_owner(which_model)
    @object = which_model.find(params[:id])
    unless(@object.user == current_user || user_is_an_admin)
      flash[:danger] = "You do not have permission for this action"
      redirect_to(login_url) 
    end
  end
  
  def redirect_for_students
    redirect_to(login_url) if current_user.type == "Student"
  end
  
  def update_current_class
    current_user.update(:current_class => @seminar.id)
  end

  def check_if_term_needs_updated
    current_term = @school.term
    current_term_ending_date = Date.strptime(@school.term_dates[@school.term][1], "%m/%d/%Y")
    @school.update(:term => current_term + 1) if Date.today > current_term_ending_date.to_date
  end
end
