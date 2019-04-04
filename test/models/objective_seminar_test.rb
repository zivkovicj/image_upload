require 'test_helper'

class ObjectiveSeminarTest < ActiveSupport::TestCase
  
  test "refresh students needed" do
    setup_users
    setup_seminars
    setup_objectives
    setup_scores
    
    first_obj = @seminar.objectives.first
    this_obj_sem = ObjectiveSeminar.find_by(:seminar => @seminar, :objective => first_obj)
    obj_stud_1 = ObjectiveStudent.find_by(:user => @student_1, :objective => first_obj)
    obj_stud_2 = ObjectiveStudent.find_by(:user => @student_2, :objective => first_obj)
    obj_stud_3 = ObjectiveStudent.find_by(:user => @student_3, :objective => first_obj)
    studs_in_class = @seminar.students.count
    
    first_obj.objective_students.update_all(:ready => true, :points_all_time => 3)  
    obj_stud_1.update(:ready => false, :points_all_time => 0)
    obj_stud_2.update(:ready => false, :points_all_time => 0)
    obj_stud_3.update(:ready => false, :points_all_time => 0)
    
    this_obj_sem.students_needed_refresh
    assert_equal studs_in_class - 3, this_obj_sem.reload.students_needed
  
    obj_stud_1.update(:ready => true, :points_all_time => 9) #Ready now, but shouldn't be counted as a needed student because she passed
    obj_stud_2.update(:ready => true, :points_all_time => 0) #Ready now, and still needs this objective. Should be counted with needed students
    #Student_3 hasn't changed, so still should not be counted for not being ready
    # Students needed should only have decreased by 1 since the last assertion
    
    this_obj_sem.students_needed_refresh
    assert_equal studs_in_class - 2, this_obj_sem.reload.students_needed
  end
  
end
