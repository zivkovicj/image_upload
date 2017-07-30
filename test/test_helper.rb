ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/reporters"
require 'capybara/rails'
Minitest::Reporters.use!


class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  include ApplicationHelper

  # Add more helper methods to be used by all tests here...
  
  def setup_objectives
    objectives(:objective_40).update(:user_id => users(:archer).id)
    objectives(:objective_50).update(:user_id => users(:archer).id)
    objectives(:objective_60).update(:user_id => users(:archer).id)
    objectives(:objective_90).update(:user_id => users(:archer).id)
    objectives(:objective_120).update(:user_id => users(:archer).id)
    objectives(:objective_130).update(:user_id => users(:archer).id)
    objectives(:objective_140).update(:user_id => users(:archer).id)
    objectives(:objective_150).update(:user_id => users(:archer).id)
    objectives(:objective_160).update(:user_id => users(:zacky).id)
    
    assign_for_quiz = objectives(:objective_10)
    assign_for_quiz.label_objectives.create(:label => @admin_l, :quantity => 4)
    assign_for_quiz.label_objectives.create(:label => @user_l, :quantity => 2, :point_value => 2)
  end
  
  def setup_labels
    labels(:one).update(:user => users(:michael))
    labels(:two).update(:user => users(:michael))
    labels(:three).update(:user => users(:archer))
    labels(:four).update(:user => users(:zacky))
    labels(:five).update(:user => users(:zacky))
    
    @unlabeled_l = labels(:one)
    @admin_l = labels(:two)
    @user_l = labels(:three)
    @other_l_pub = labels(:four)
    @other_l_priv = labels(:five)
  end
  
  def setup_questions
    questions(:one).update(:user => users(:michael))
    questions(:two).update(:user => users(:archer))
    questions(:three).update(:user => users(:zacky))
    questions(:four).update(:user => users(:zacky))
    
    questions(:one).update(:label => labels(:two))
    questions(:two).update(:label => labels(:three))
    questions(:three).update(:label => labels(:four))
    questions(:four).update(:label => labels(:five))
    
    @admin_q = questions(:one)
    @user_q = questions(:two)
    @other_q_pub = questions(:three)
    @other_q_priv = questions(:four)
    
    30.times do |n|
      Question.find_by(:prompt => "Admin_question_#{n}").update(:user => users(:michael), :label => (@admin_l))
    end
    
    10.times do |n|
      Question.find_by(:prompt => "User_question_#{n}").update(:user => users(:archer), :label => (@user_l))
    end
  end
  
  # Returns true if a test user is logged in.
  def is_logged_in?
    !session[:user_id].nil?
  end
  
  # Log in as a particular user
  def log_in_as(user)
    session[:user_id] = user.id
    if user.role == "student"
        session[:user_type] = "student"
    else
        session[:user_type] = "teacher"
    end
  end
  
  def capybara_admin_login
    visit('/')
    click_on('Log In')
    fill_in('username', :with => 'michael@example.com')
    fill_in('Password', :with => 'password')
    click_on('Log In')
  end
  
  def capybara_teacher_login
    visit('/')
    click_on('Log In')
    fill_in('username', :with => 'archer@example.com')
    fill_in('Password', :with => 'password')
    click_on('Log In')
  end
  
  def setup_scores()
    Seminar.all.each do |seminar|
      seminar.objectives.each do |objective|
        seminar.students.each do |student|
          if student.objective_students.find_by(:objective_id => objective.id) == nil
            student.objective_students.create(:objective_id => objective.id, :points => 75)
          end
        end
      end
    end
  end
  
  def setup_consultancies()
    c1 = seminars(:one).consultancies.create
    t1 = c1.teams.create(:objective => objectives(:objective_10), :consultant => students(:student_2))
    t1.students << students(:student_2)
    t1.students << students(:student_3)
    t1.students << students(:student_4)
    t1.students << students(:student_5)
  end
  
  def capybara_student_login(student)
    visit('/')
    click_on('Log In')
    fill_in('username', :with => student.username)
    fill_in('Password', :with => 'password')
    click_on('Log In')
    click_on('1st Period')
  end
end

class ActionDispatch::IntegrationTest
  
  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL

  # Reset sessions and driver between tests
  # Use super wherever this method is redefined in your individual test classes
  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
  
  # Log in as a particular user.
  def log_in_as(user, password: 'password', remember_me: '1')
    if user.role == "student"
        post login_path, params: { session: { email: user.username,
                                        password: password,
                                        remember_me: remember_me } }
        session[:user_type] = "student"
    else
        post login_path, params: { session: { email: user.email,
                                        password: password,
                                        remember_me: remember_me } }
        session[:user_type] = "teacher"
    end
  end
end
