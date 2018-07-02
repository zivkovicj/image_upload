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
  
  def friendly_date(input)
      Date.strptime(input, "%m/%d/%Y")
  end
  
  def redirect_for_students
    redirect_to(login_url) if current_user.type == "Student"
  end
  
  def update_current_class
    current_user.update(:current_class => @seminar.id)
  end

  def check_if_term_needs_updated
    current_term = @school.term
    current_term_ending_date = friendly_date(@school.term_dates[@school.term][1])
    @school.update(:term => current_term + 1) if Date.today > current_term_ending_date.to_date
  end
  
  def create_commodities
    @teacher.commodities.each do |commode|
      today_weekday_num = Date.today.wday
      days_since_last = (Date.today - commode.date_last_produced.to_date).to_i
      
      if (today_weekday_num >= commode.production_day && days_since_last > 1) || (days_since_last > 7)
        num_students = @teacher.students.count
        full_term_production = num_students * commode.production_rate
        
        this_term = @school.term
        term_length = (friendly_date(@school.term_dates[this_term][1]) - friendly_date(@school.term_dates[this_term][0])).to_i
        term_weeks = term_length / 7
        quantity_to_produce = (full_term_production / term_weeks).round
        commode.update(:quantity => commode.quantity + quantity_to_produce, :date_last_produced => Date.today)
      end
    end
  end
end
