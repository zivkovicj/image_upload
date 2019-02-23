require 'test_helper'

class ObjectiveStudentTest < ActiveSupport::TestCase

    test "update ready" do
        setup_users
        
        main_assign = objectives(:objective_60)
        pre_assign_1 = objectives(:objective_50)
        pre_assign_2 = objectives(:objective_40)
        
        set_specific_score(@student_1, pre_assign_1, 0)
        set_specific_score(@student_1, pre_assign_2, 0)
        this_obj_stud = @student_1.objective_students.find_or_create_by(:objective => main_assign)
        assert_not this_obj_stud.ready
        
        set_specific_score(@student_1, pre_assign_1, 10)
        set_specific_score(@student_1, pre_assign_2, 10)
        this_obj_stud.set_ready
        this_obj_stud.reload
        assert this_obj_stud.ready
        
        set_specific_score(@student_1, pre_assign_1, 0)
        set_specific_score(@student_1, pre_assign_2, 10)
        this_obj_stud.set_ready
        this_obj_stud.reload
        assert_not this_obj_stud.ready
    end
end
