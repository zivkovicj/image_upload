require 'test_helper'

class StudentsMoveClassTest < ActionDispatch::IntegrationTest
    
    def setup
        setup_users
        setup_seminars
        setup_scores
    end
    
    test "move student to different class" do
        sem_2 = @teacher_1.own_seminars.second
        assert @student_2.seminars.include?(@seminar)
        assert @seminar.students.include?(@student_2)
        assert_not @student_2.seminars.include?(sem_2)
        assert_not sem_2.students.include?(@student_2)
        
        capybara_login(@teacher_1)
        click_on("scoresheet_#{@seminar.id}")
        click_on(@student_2.last_name_first)
        click_on("Edit/Move Student")
        find("#toggle_text").click
        click_on("Move to #{sem_2.name}")
        
        @student_2.reload
        sem_2.reload
        assert_not @student_2.seminars.include?(@seminar)
        assert_not @seminar.students.include?(@student_2)
        assert @student_2.seminars.include?(sem_2)
        assert sem_2.students.include?(@student_2)
    end
    
end