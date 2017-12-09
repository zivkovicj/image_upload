ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/reporters"
require 'capybara/rails'
Minitest::Reporters.use!

CarrierWave.root = 'test/fixtures/files'

class CarrierWave::Mount::Mounter
  def store!
    # Not storing uploads in the tests
  end
end


class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  
  include ApplicationHelper
  
  include ActionDispatch::TestProcess

  CarrierWave.root = Rails.root.join('test/fixtures/files')
  
  def after_teardown
    super
    CarrierWave.clean_cached_files!(0)
  end
  
  def disable_images
    Question.where.not(:picture_id => nil).update_all(:picture_id => nil) 
  end
  
  def setup_users
    @admin_user = users(:michael)
    @teacher_1 = users(:archer)
    @other_teacher = users(:zacky)
    @unverified_teacher = users(:user_1)
    @student_1 = users(:student_1)
    @student_2 = users(:student_2)
    @student_3 = users(:student_3)
    @other_school_student = users(:other_school_student)
    @student_90 = users(:student_90)
  end
  
  def setup_schools
    @school = schools(:school_1)
  end
  
  def setup_seminars
    @seminar = seminars(:one)
  end
  
  def setup_consultancies
    c1 = seminars(:one).consultancies.create
    t1 = c1.teams.create(:objective => objectives(:objective_10), :consultant => users(:student_2))
    t1.users << users(:student_2)
    t1.users << users(:student_3)
    t1.users << users(:student_4)
    t1.users << users(:student_5)
    
    c2 = seminars(:one).consultancies.create
    t2 = c2.teams.create(:objective => objectives(:objective_20), :consultant => users(:student_3))
    t2.users << users(:student_2)
    t2.users << users(:student_3)
    t2.users << users(:student_4)
    t2.users << users(:student_5)
    
    @consultancy_from_setup = Consultancy.all[-1]
    @other_consultancy = Consultancy.all[-2]
  end
  
  def setup_objectives
    @objective_10 = objectives(:objective_10)
    @objective_20 = objectives(:objective_20)
    @objective_30 = objectives(:objective_30)
    @objective_40 = objectives(:objective_40)
    @objective_50 = objectives(:objective_50)
    @own_assign = objectives(:objective_60)
    @assign_to_add = objectives(:objective_70)
    @objective_80 = objectives(:objective_80)
    @sub_preassign = objectives(:objective_100)
    @preassign_to_add = objectives(:objective_110)
    @already_preassign_to_main = objectives(:objective_120)
    @already_preassign_to_super = objectives(:objective_130)
    @main_objective = objectives(:objective_140)
    @super_objective = objectives(:objective_150)
    @other_teacher_objective = objectives(:objective_160)
  end
  
  def setup_labels
    @unlabeled_l = labels(:unlabeled_label)
    @admin_l = labels(:admin_label)
    @user_l = labels(:user_label)
    @other_l_pub = labels(:other_label_public)
    @other_l_priv = labels(:other_label_private)
    @fill_in_label = labels(:fill_in_label)
  end
  
  def setup_questions
    @admin_q = questions(:one)
    @user_q = questions(:two)
    @other_q_pub = questions(:three)
    @other_q_priv = questions(:four)
  end
  
  def setup_pictures
    @admin_p = pictures(:cheese_logo)
    @user_p = pictures(:two)
    @other_p = pictures(:three)
  end
  
  def setup_scores
    Seminar.all.each do |seminar|
      seminar.objectives.each do |objective|
        seminar.students.each do |student|
          if student.objective_students.find_by(:objective => objective) == nil
            student.objective_students.create(:objective => objective, :points => rand(11))
          end
        end
      end
    end
  end
  
  def setup_goals
    Seminar.all.each do |seminar|
      seminar.students.each do |stud|
        4.times do |n|
          stud.goal_students.create(:seminar_id => seminar.id)
        end
      end
    end
  end
  
  def is_logged_in?
    !session[:user_id].nil?
  end
  
  def log_in_as(user)
    session[:user_id] = user.id
  end
  
  def log_out
    click_on("Account")
    click_on("Log out")
  end
  
  def assert_on_teacher_page
    assert_text("Teacher Since:")
  end
  
  def assert_not_on_teacher_page
    assert_no_text("Teacher Since:")
  end
  
  def assert_on_admin_page
    assert_text("Admin Control Page")
  end
  
  def assert_not_on_admin_page
    assert_no_text("Admin Control Page")
  end
  
  def assert_on_scoresheet
    assert_text("#{@seminar.name} Scoresheet")
  end
  
  def capybara_login(user)
    visit('/')
    click_on('Log In')
    fill_in('username', :with => user.email)
    fill_in('Password', :with => 'password')
    click_on('Log In')
  end
  
  def go_to_first_period
    capybara_login(@student_2)
    click_on('1st Period')
  end
  
  def go_to_create_student_view
    capybara_login(@teacher_1)
    click_on("scoresheet_#{@seminar.id}")
    click_on('Create New Students')
  end
  
  def establish_objectives(seminar)
    (0..3).each do |n|
      this_obj = instance_variable_set("@obj_#{n}", seminar.objectives[n])
      instance_variable_set("@os_#{n}", this_obj.objective_seminars.find_by(:seminar => seminar))
    end
  end
  
  def begin_quiz
    click_link("#{@objective_10.name}", match: :first)
  end
  
  def answer_quiz_randomly
    10.times do
      choose("choice_bubble_1")
      click_on("Next Question")
    end
  end
  
  def teacher_editing_stuff(teacher, button_text)
    select('Mrs.', :from => 'teacher_title')
    fill_in "teacher_first_name", with: "Burgle"
    fill_in "teacher_last_name", with: "Cut"
    fill_in "teacher_email", with: "Burgle@Cut.com"
    fill_in "teacher_password", with: "bigbigbigbig"
    fill_in "teacher_password_confirmation", with: "bigbigbigbig"
    click_on(button_text)
  
    @this_teacher = teacher || Teacher.last
    @this_teacher.reload
    assert_equal "Mrs.", @this_teacher.title
    assert_equal "Burgle", @this_teacher.first_name
    assert_equal "Cut", @this_teacher.last_name
    assert_equal "burgle@cut.com", @this_teacher.email
    assert @this_teacher.authenticate("bigbigbigbig")
  end
  
  def reload_oss
    @os_0.reload
    @os_1.reload
    @os_2.reload
    @os_3.reload
  end
  
  def fill_prompt(a)
    fill_in "prompt_#{a}", with: @new_prompt[a]
  end
    
  def fill_choice(a, b)
    fill_in "question_#{a}_choice_#{b}", with: @new_choice[a][b]
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
        post login_path, params: { session: { email: user.email,
                                        password: password,
                                        remember_me: remember_me } }
  end
end
