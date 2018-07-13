require 'test_helper'

class TeachersIndexTest < ActionDispatch::IntegrationTest

  def setup
    setup_users
    setup_schools
  end

  test "teacher index" do
    log_in_as(@admin_user)
    get teachers_path
    assert_template 'teachers/index'
    assert_select 'div.pagination'
    first_page_of_teachers = Teacher.paginate(page: 1)
    first_page_of_teachers.each do |teacher|
      assert_select 'a[href=?]', teacher_path(teacher), text: teacher.first_name
    end
    assert_difference 'Teacher.count', -1 do
      delete teacher_path(@teacher_1)
    end
  end

  test "teacher index as non-admin" do
    log_in_as(@teacher_1)
    get teachers_path
    assert_redirected_to login_url
  end
  
  test "back button" do
    capybara_login(@admin_user)
    click_on("Teachers Index")
    assert_selector("h2", :text => "All Teachers")
    assert_not_on_admin_page
    click_on("back_button")
    assert_on_admin_page 
  end
  
  test "delete teacher" do
    setup_objectives()
    
    old_teacher_count = Teacher.count
    old_objective_count = Objective.count
    archers_objectives = Objective.where(:user => @teacher_1).count
    assert archers_objectives > 0
    
    capybara_login(@admin_user)
    click_on("Teachers Index")
    find("#delete_#{@teacher_1.id}").click
    click_on("confirm_#{@teacher_1.id}")
    
    assert_equal old_teacher_count - 1, Teacher.count
    assert_equal old_objective_count - archers_objectives, Objective.count
  end
end