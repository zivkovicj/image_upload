require 'test_helper'

class GoalsEditTest < ActionDispatch::IntegrationTest
    
    def setup
        setup_users
        setup_seminars
        setup_scores
        setup_goals
        
        @seminar.update(:term => 0)
        @seminar.update(:which_checkpoint => 0)
    end
    
    def go_to_goals
       click_on("#{@seminar.name} student goals") 
    end
    
    test "student edits goal" do
        capybara_login(@teacher_1)
        go_to_goals
        assert_selector('h4', :text => "#{@seminar.students.count} students need you to choose/approve their goals for this term.")
        assert_no_selector('h5', :text => Goal.second.name)
        
        log_out
        
        go_to_first_period
        click_on("Edit This Goal")
        select("#{Goal.second.name}", :from => 'goal_student_goal_id')
        select("60%", :from => 'goal_student_target')
        click_on("Save This Goal")
        
        @gs = @student_2.goal_students.where(:seminar => @seminar)[0]
        assert_equal Goal.second, @gs.goal
        assert_equal 60, @gs.target
        assert_equal false, @gs.approved
        assert_equal "Play something kind", @gs.checkpoints[0].action
        assert_equal "I will be kind (?) % of the time so far.", @gs.checkpoints[1].action
        assert_equal "Play something kind", @gs.checkpoints[2].action
        assert_equal "I will be kind 60 % of the time.", @gs.checkpoints[3].statement
         
        assert_text("Goal for Term 1")
        select("Eat something kind", :from => "syl[#{@gs.checkpoints.first.id}][action]")
        click_on("Save These Checkpoints")
        
        assert_selector('h2', :text => "Current Stars for this Grading Term")
        
        @gs.reload
        assert_equal "Eat something kind", @gs.checkpoints[0].action
        assert_equal "I will be kind (?) % of the time so far.", @gs.checkpoints[1].action   # Not changed in the previous screen.
        assert_equal "Play something kind", @gs.checkpoints[2].action
        log_out
        
        capybara_login(@teacher_1)
        go_to_goals
        assert_selector('h4', :text => "#{@seminar.students.count} students need you to choose/approve their goals for this term.")
        assert_selector('h5', :text => Goal.second.name)
    end
    
    test "teacher views goals" do
        # Edit test has the control case, where some goals need approval.
        GoalStudent.all.update_all(:approved => true)
        
        capybara_login(@teacher_1)
        go_to_goals
        assert_no_selector('h1', :text => "Approve Student Goals")
        assert_selector('h1', :text => "View Student Goals")
    end
    
    test "dont choose goal" do
        @seminar.update(:term => 0)
        @seminar.update(:which_checkpoint => 0)
        go_to_first_period
        click_on("Edit This Goal")
        
        click_on("Save This Goal")
        
        assert_selector('h2', :text => "Current Stars for this Grading Term")
        
        @gs = @student_2.goal_students.where(:seminar => @seminar)[0]
        assert_nil @gs.goal
    end
        
end