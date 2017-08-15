require 'test_helper'

class SeminarStudentsControllerTest < ActionDispatch::IntegrationTest
  
  def setup
    setup_users
    setup_seminars
    @ss = seminar_students(:ss_1)
  end
  
  
  test "Must be logged in as correct user" do
    assert_no_difference ['SeminarStudent.count','@student_1.seminar_students.count','@seminar.students.count'] do
      delete seminar_student_path(@ss)
    end
    assert_redirected_to login_url
  end
end
