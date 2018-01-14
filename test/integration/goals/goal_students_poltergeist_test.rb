require 'test_helper'

class GoalStudentsEditTest < ActionDispatch::IntegrationTest


    def setup
        setup_users
        setup_seminars
    end
    
    def goal_test_opening
        poltergeist_stuff
        setup_goals
        setup_scores
        update_term_and_checkpoint
        @gs = @student_2.goal_students.find_by(:seminar => @seminar, :term => @seminar.term)
    end
    
    def update_term_and_checkpoint
        @seminar.update(:term => 0)
        @seminar.update(:which_checkpoint => 0)
    end
    
    def set_student_goals
        @gs.update(:goal => Goal.second, :target => 60)
    end
        
    test "teacher changes target" do
        goal_test_opening
        set_student_goals
        
        capybara_login(@teacher_1)
        go_to_goals
        sleep(0.5)
        within(:css, "#approval_cell_#{@gs.id}") do
            assert_text("60")
            assert_no_text("70")
            assert_text("Approve")
        end
        select("70%", :from => "target_select_#{@gs.id}")
        within(:css, "#approval_cell_#{@gs.id}") do
            assert_text("70")
            assert_no_text("60")
            assert_no_text("Approve")
        end
        
        @gs.reload
        assert @gs.approved
        assert_equal 70, @gs.target
    end
        
    test "teacher approves goal" do
        goal_test_opening
        
        capybara_login(@teacher_1)
        go_to_goals
        sleep(0.5)
        find('h4', :text => "#{@seminar.students.count} students need you to choose/approve their goals for this term.", :visible => true)
        within(:css, "#approval_cell_#{@gs.id}") do
            assert_text("No Goal Set")
            assert_no_text(Goal.second.name)
            assert_no_text("Approve")
        end
        click_on("Log out")
        
        set_student_goals
        
        capybara_login(@teacher_1)
        go_to_goals
        sleep(0.5)
        assert_selector('h4', :text => "#{@seminar.students.count} students need you to choose/approve their goals for this term.")
        within(:css, "#approval_cell_#{@gs.id}") do
            assert_no_text("No Goal Set")
            assert_text(Goal.second.name)
            assert_text("Approve")
        end
        find("#approval_button_#{@gs.id}").click
        within(:css, "#approval_cell_#{@gs.id}") do
            assert_no_text("No Goal Set")
            assert_text(Goal.second.name)
            assert_no_text("Approve")
        end
        @gs.reload
        assert @gs.approved
    end
    
    test "teacher changes goal" do
        goal_test_opening
        set_student_goals
        
        capybara_login(@teacher_1)
        go_to_goals
        sleep(0.5)
        within(:css, "#approval_cell_#{@gs.id}") do
            assert_no_text("No Goal Set")
            assert_text(Goal.second.name)
            assert_text("Approve")
        end
        select("#{Goal.first.name}", :from => "goal_select_#{@gs.id}")
        within(:css, "#approval_cell_#{@gs.id}") do
            assert_text(Goal.first.name)
            assert_no_text(Goal.second.name)
            assert_no_text("Approve")
        end
        
        @gs.reload
        assert_equal Goal.first, @gs.goal
        assert @gs.approved
        assert_equal "Play something awesome", @gs.checkpoints[0].action
        assert_equal "Be halfway awesome", @gs.checkpoints[1].action
        assert_equal "Play something awesome", @gs.checkpoints[2].action
        assert_equal "I will be awesome for (?)% of the school days this term.", @gs.checkpoints[3].action
        assert_equal "I will be awesome for 60% of the school days this term.", @gs.checkpoints[3].statement
    end
        
end