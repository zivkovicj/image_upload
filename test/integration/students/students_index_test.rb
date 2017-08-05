require 'test_helper'

class StudentsIndexTest < ActionDispatch::IntegrationTest

  def setup
    setup_users()
    setup_seminars
  end

  test "Student Index" do
    @admin     = users(:michael)
    log_in_as(@admin_user)
    get students_path
    assert_template 'students/index'
    assert_select 'div.pagination'
    first_page_of_students = Student.paginate(page: 1)
    first_page_of_students.each do |student|
      assert_select 'a[href=?]', student_path(student), text: "delete"
    end
    assert_difference 'Student.count', -1 do
      delete student_path(@student_1)
    end
  end
  
  test "students back button" do
    capybara_login(@admin_user)
    click_on("Students Index")
    assert_selector("h1", :text => "All Students")
    assert_not_on_admin_page
    click_on("back_button")
    assert_on_admin_page
  end
end