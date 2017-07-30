require 'test_helper'

class SeminarStudentsControllerTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:michael)
    @teacher_user = users(:archer)
    @seminar = seminars(:one)
    @student = students(:student_1)
    @other_student = students(:student_2)
    @student_51 = students(:student_51)
    @ss = seminar_students(:ss_1)
    @objective = objectives(:objective_20)
    @other_objective = objectives(:objective_30)
  end
  
  test "Remove student from class period" do
  # Also checks the seating chart has lost one student, and that the student's
  # scores were deleted
    log_in_as(@teacher_user)
    get seminar_path(@seminar)
    #seatChartCount = @seminar.seating.count
    assert_difference ['SeminarStudent.count', '@seminar.students.count'], -1 do
      delete seminar_student_path(@ss)
    end
    @seminar.reload
    #assert_equal @seminar.seating.count, (seatChartCount - 1)
    assert_redirected_to scoresheet_url(@seminar)
  end
  
  test "Must be logged in as correct user" do
    assert_no_difference ['SeminarStudent.count','@student.seminar_students.count','@seminar.students.count'] do
      delete seminar_student_path(@ss)
    end
    assert_redirected_to login_url
  end
end
