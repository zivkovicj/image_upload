require 'test_helper'

class StudentsMoveOrRemoveTest < ActionDispatch::IntegrationTest
    
    def setup
        setup_users
        setup_seminars
        setup_scores
        setup_goals
    end
    
    test "move student to different class" do
        gs_term_1 = @student_2.goal_students.find_by(:seminar => @seminar, :term => 1)
        gs_term_1.update(:goal => Goal.second)
        gs_term_1.checkpoints.find_by(:sequence => 0).update(:action => gs_term_1.goal.actions[0][2])
        gs_term_1.checkpoints.find_by(:sequence => 1).update(:achievement => 95)
        @student_2.goal_students.find_by(:seminar => @seminar, :term => 2).checkpoints.find_by(:sequence => 2).update(:teacher_comment => "Sup dude!")
        @student_2.goal_students.find_by(:seminar => @seminar, :term => 2).checkpoints.find_by(:sequence => 3).update(:student_comment => "Sup teach!")
        sem_2 = @teacher_1.seminars.second
        assert_nil @student_2.goal_students.find_by(:seminar => sem_2)
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
        
        new_gs_1 = @student_2.goal_students.find_by(:seminar => sem_2, :term => 1)
        new_gs_2 = @student_2.goal_students.find_by(:seminar => sem_2, :term => 2)
        
        assert_equal Goal.second, new_gs_1.goal
        assert_nil new_gs_2.goal
        
        assert_equal Goal.second.actions[0][2], new_gs_1.checkpoints.find_by(:sequence => 0).action
        assert_equal 95, new_gs_1.checkpoints.find_by(:sequence => 1).achievement
        assert_equal "Sup dude!", new_gs_2.checkpoints.find_by(:sequence => 2).teacher_comment
        assert_equal "Sup teach!", new_gs_2.checkpoints.find_by(:sequence => 3).student_comment
        
        assert_nil new_gs_2.checkpoints.find_by(:sequence => 0).action
        assert_nil new_gs_2.checkpoints.find_by(:sequence => 1).achievement
        assert_nil new_gs_1.checkpoints.find_by(:sequence => 2).teacher_comment
        assert_nil new_gs_1.checkpoints.find_by(:sequence => 3).student_comment
    end
    
    test "remove student from class" do
        capybara_login(@teacher_1)
        click_on("scoresheet_#{@seminar.id}")
        click_on(@student_2.last_name_first)
        click_on("Edit/Move Student")
        find("#delete_#{@seminar.id}").click
        
        @student = @student_2
        click_on("confirm_#{@seminar.id}")
        
        assert_not @seminar.students.include?(@student_2)
        assert_not @student_2.seminars.include?(@seminar)
    end
    
end