require 'test_helper'

class SchoolTest < ActiveSupport::TestCase
  
  def setup
    setup_schools
  end
  
  test "unverified_teachers" do
    @last_teacher = Teacher.last
    @unverified_teachers = @school.check_for_unverified_teachers
    assert @unverified_teachers.include?(@last_teacher)
    assert_not @unverified_teachers.include?(@teacher_1)
  end
end
