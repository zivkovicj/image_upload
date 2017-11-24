require 'test_helper'

class GoalsEditTest < ActionDispatch::IntegrationTest
    
    def setup
        setup_users
        setup_seminars
        setup_scores
        setup_goals
    end
    
    test "edit and approve goal" do
        capybara_login(@teacher_1)
        click_on("#{@seminar.name} student goals")
        assert_no_selector('h5', :text => Goal.second.name)
        
        log_out
        
        go_to_first_period
        click_on("edit_goal_student_0")
        select("#{Goal.second.name}", :from => 'goal_student_goal_id')
        click_on("Save This Goal")
        
        @gs = @student_2.goal_students.find_by(:seminar => @seminar, :term => 1)
        assert_equal Goal.second, @gs.goal
        assert_equal false, @gs.approved
         
        assert_text("Goal for Term 1")
        select("Eat something kind", :from => "syl[#{@gs.checkpoints.first.id}][action]")
        click_on("Save These Checkpoints")
        
        assert_selector('h2', :text => "Current Stars for this Grading Term")
        
        assert_equal "Eat something kind", @gs.checkpoints[0].action
        assert_equal "Be halfway kind", @gs.checkpoints[1].action
        assert_equal "Play something kind", @gs.checkpoints[2].action
        
        log_out
        
        capybara_login(@teacher_1)
        click_on("#{@seminar.name} student goals")
        assert_selector('h5', :text => Goal.second.name)
        
        
    end
    
    test "don't choose goal" do
        go_to_first_period
        click_on("edit_goal_student_0")
        
        click_on("Save This Goal")
        
        assert_selector('h2', :text => "Current Stars for this Grading Term")
        
        @gs = @student_2.goal_students.find_by(:seminar => @seminar, :term => 1)
        assert_nil @gs.goal
    end
        
end