require 'test_helper'

class StudentsIndexTest < ActionDispatch::IntegrationTest

  def setup
    @admin     = users(:michael)
    @non_admin = users(:archer)
    @student = students(:student_1)
    @seminar = seminars(:one)
  end

  test "Student Index" do
    @admin     = users(:michael)
    log_in_as(@admin)
    get students_path
    assert_template 'students/index'
    assert_select 'div.pagination'
    first_page_of_students = Student.paginate(page: 1)
    first_page_of_students.each do |student|
      assert_select 'a[href=?]', student_path(student), text: "delete"
    end
    assert_difference 'Student.count', -1 do
      delete student_path(@student)
    end
  end
  
  test "students back button" do
    capybara_admin_login()
    click_on("Students Index")
    assert_selector("h1", :text => "Search for Students")
    assert_no_text("Desk-Consultant Facilitator Since:")
    click_on("back_button")
    assert_text("Desk-Consultant Facilitator Since:") 
  end
end