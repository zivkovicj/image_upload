require 'test_helper'

class TeachersShowTest < ActionDispatch::IntegrationTest
    
    include UsersHelper
    
    def setup
        setup_users
        setup_schools
        @right_teacher = users(:user_2)
        @wrong_teacher = users(:user_1)
        @ignored_teacher = users(:user_3)
    end
    
    test "show" do
        log_in_as @teacher_1
        get teacher_path(@teacher_1)
        assert_template 'teachers/show'
        assert_select 'title', full_title(@teacher_1.name_with_title)
        #assert_select 'h1>img.gravatar'
        assert_match @teacher_1.seminars.count.to_s, response.body
        @teacher_1.seminars.each do |seminar|
            assert_match seminar.name, response.body
        end
    end
    
    test "approve unverified teachers" do
        assert_equal 0, @right_teacher.verified
        assert_equal 0, @wrong_teacher.verified
        assert_equal 0, @ignored_teacher.verified
        @right_teacher_student = Student.all[55]
        @wrong_teacher_student = Student.all[56]
        @ignored_teacher_student = Student.all[57]
        @right_teacher_student.update(:sponsor => @right_teacher, :verified => 0)
        @wrong_teacher_student.update(:sponsor => @wrong_teacher, :verified => 0)
        @ignored_teacher_student.update(:sponsor => @ignored_teacher, :verified => 0)
        
        capybara_login(@teacher_1)
        assert_text(verify_waiting_teachers_message)
        click_on("goto_verify")
        
        choose("teacher_#{@right_teacher.id}_approve")
        choose("teacher_#{@wrong_teacher.id}_decline")
        click_on("Submit these approvals")
        
        assert_equal 1, @right_teacher.reload.verified
        assert_equal 0, @ignored_teacher.reload.verified
        assert_equal (-1), @wrong_teacher.reload.verified
        assert_equal 1, @right_teacher_student.reload.verified
        assert_equal 0, @ignored_teacher_student.reload.verified
        assert_equal 0, @wrong_teacher_student.reload.verified
    end
    
    test "unverified message doesn't appear when useless" do
        @school.teachers.update_all(:verified => 1)
        capybara_login(@teacher_1)
        assert_no_text(verify_waiting_teachers_message)
    end
    
    test "unverified message should not appear for non mentor teacher" do
        assert @school.unverified_teachers
        
        capybara_login(@wrong_teacher)
        
        assert_no_text(verify_waiting_teachers_message)
    end
end