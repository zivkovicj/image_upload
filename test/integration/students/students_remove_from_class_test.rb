require 'test_helper'

class StudentsRemoveFromClassTest < ActionDispatch::IntegrationTest
    
    include StudentsHelper
    
    def setup
        setup_users 
        setup_seminars
        setup_scores
    end
    
    test "remove a student from a class period" do
        capybara_login(@teacher_1)
        click_on("scoresheet_#{@seminar.id}")
        click_on(@student_2.last_name_first)
        click_on("Edit/Move Student")
        #debugger
        find("#delete_30").click
        @student = @student_2
        click_on(confirm_remove_student)
        
        assert_not @seminar.students.include?(@student_2)
        assert_not @student_2.seminars.include?(@seminar)
    end
    
    
    
end