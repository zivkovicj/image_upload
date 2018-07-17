require 'test_helper'

class TeachersShowTest < ActionDispatch::IntegrationTest
    
    include TeachersHelper
    
    def setup
        setup_users
        setup_schools
    end
    
    test "show" do
        log_in_as @teacher_1
        get teacher_path(@teacher_1)
        assert_template 'teachers/show'
        assert_select 'title', full_title(@teacher_1.name_with_title)
        #assert_select 'h2>img.gravatar'
        assert_match @teacher_1.seminars.count.to_s, response.body
        @teacher_1.seminars.each do |seminar|
            assert_match seminar.name, response.body
        end
    end
    
    test "unverified message does not appear when useless" do
        @school.teachers.update_all(:verified => 1)
        capybara_login(@teacher_1)
        assert_no_text(verify_waiting_teachers_message)
    end
    
    test "unverified message should not appear for non admin teacher" do
        @other_teacher.update(:school_admin => 0)
        assert @school.unverified_teachers
        
        capybara_login(@other_teacher)
        
        assert_no_text(verify_waiting_teachers_message)
    end
end