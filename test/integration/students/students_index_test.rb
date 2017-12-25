require 'test_helper'

class StudentsIndexTest < ActionDispatch::IntegrationTest

  def setup
    setup_users
    setup_seminars
  end


  # Most test functions are in the student_search_test
  
  test "students back button" do
    capybara_login(@admin_user)
    click_on("Students Index")
    assert_selector("h1", :text => "All Students")
    assert_not_on_admin_page
    click_on("back_button")
    assert_on_admin_page
  end
  
  test "delete student" do
      this_stud = Student.order(:last_name).first
      old_stud_count = Student.count
      
      capybara_login(@admin_user) 
      click_on("Students Index")
      
      fill_in "search_field", with: this_stud.user_number
      choose('Student number')
      click_button('Search')
      find("#delete_#{this_stud.id}").click
      click_on("confirm_#{this_stud.id}")

      assert_equal old_stud_count - 1, Student.count
  end
end