require 'test_helper'

class TeachersShowTest < ActionDispatch::IntegrationTest
    
    include UsersHelper
    
    def setup
        setup_users
    end
    
    test "show" do
        log_in_as @teacher_1
        get teacher_path(@teacher_1)
        assert_template 'teachers/show'
        assert_select 'title', full_title(@teacher_1.name_with_title)
        #assert_select 'h1>img.gravatar'
        assert_match @teacher_1.own_seminars.count.to_s, response.body
        @teacher_1.own_seminars.each do |seminar|
            assert_match seminar.name, response.body
        end
    end
    
    test "approve unverified teachers" do
        @school = @teacher_1.school
        @right_teacher = users(:user_2)
        @wrong_teacher = users(:user_1)
        @ignored_teacher = users(:user_3)
        assert_equal 0, @right_teacher.verified
        assert_equal 0, @wrong_teacher.verified
        assert_equal 0, @ignored_teacher.verified
        
        capybara_login(@teacher_1)
        assert_text(verify_waiting_teachers_message)
        click_on("goto_verify")
        
        choose("teacher_#{@right_teacher.id}_approve")
        choose("teacher_#{@wrong_teacher.id}_decline")
        click_on("Submit these approvals")
        
        @right_teacher.reload
        @wrong_teacher.reload
        @ignored_teacher.reload
        assert_equal 1, @right_teacher.verified
        assert_equal 0, @ignored_teacher.verified
        assert_equal (-1), @wrong_teacher.verified
    end
    
    test "unverified message doesn't appear when useless" do
        @school = @teacher_1.school
        @school.teachers.update_all(:verified => 1)
        capybara_login(@teacher_1)
        assert_no_text(verify_waiting_teachers_message)
    end
    
end