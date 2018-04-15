require 'test_helper'

class GoalStudentsPoltergeistEditTest < ActionDispatch::IntegrationTest


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
        @gs.update(:goal_id => Goal.second.id, :target => 60)
        @gs.gs_update_stuff
        @check_0 = @gs.checkpoints.find_by(:sequence => 0)
        @check_1 = @gs.checkpoints.find_by(:sequence => 1)
        @check_2 = @gs.checkpoints.find_by(:sequence => 2)
        @check_3 = @gs.checkpoints.find_by(:sequence => 3)
    end
        
    test "no goal set" do
        goal_test_opening
        
        capybara_login(@teacher_1)
        go_to_goals
        sleep(1)
        within(:css, "#goal_text_#{@gs.id}") do
            assert_text("Click to Choose Student's Goal")
            assert_no_text(Goal.second.name)
        end
        assert_no_selector('div', :id => "#approval_button_#{@gs.id}")
    end
    
    test "teacher locks goal" do
        goal_test_opening
        set_student_goals
        
        capybara_login(@teacher_1)
        go_to_goals
        sleep(1)
        within(:css, "#approval_button_#{@gs.id}") do
            assert_text("Lock This Goal")
        end
        
        find("#approval_button_#{@gs.id}").click
        within(:css, "#approval_button_#{@gs.id}") do
            assert_text("Unlock This Goal")
        end
        @gs.reload
        #debugger
        assert @gs.approved
        
        find("#approval_button_#{@gs.id}").click
        within(:css, "#approval_button_#{@gs.id}") do
            assert_text("Lock This Goal")
            assert_no_text("Unlock This Goal")
        end
        @gs.reload
        #debugger
        assert_not @gs.approved
    end
    
    test "teacher changes goal" do
        goal_test_opening
        set_student_goals
        
        assert_not_equal Goal.first, @gs.goal
        
        capybara_login(@teacher_1)
        go_to_goals
        sleep(1)
        within(:css, "#goal_text_#{@gs.id}") do
            assert_no_text("Be Awesome 24/7")
            assert_text("Be Kind")
        end
        
        find("#best_in_place_goal_student_#{@gs.id}_goal_id").click
        find("#best_in_place_goal_student_#{@gs.id}_goal_id").select(Goal.first.name)
        find("#best_in_place_goal_student_#{@gs.id}_goal_id").click
    
        within(:css, "#goal_text_#{@gs.id}") do
            assert_text("Be Awesome 24/7")
            assert_no_text("Be Kind")
        end
        
        sleep(1)
        @gs.reload
        assert_equal Goal.first, @gs.goal
        #assert_equal 85, @gs.target
        assert_equal "Play something awesome", @gs.checkpoints[0].action
        assert_equal "Be halfway awesome", @gs.checkpoints[1].action
        assert_equal "Play something awesome", @gs.checkpoints[2].action
        assert_equal "I will be awesome for (?)% of the school days this term.", @gs.checkpoints[3].action
        assert_equal "I will be awesome for 60% of the school days this term.", @gs.checkpoints[3].statement
        
    end
    
    test "teacher changes target" do
        goal_test_opening
        set_student_goals
        
        @check_2 = @gs.checkpoints.find_by(:sequence => 2)
        assert_equal 60, @gs.target
        
        capybara_login(@teacher_1)
        go_to_goals
        sleep(1)
        within(:css, "#target_span_#{@gs.id}") do
            assert_no_text("85%")
            assert_text("60%")
        end
        
        find("#best_in_place_goal_student_#{@gs.id}_target").click.select("85%")
        
        within(:css, "#target_span_#{@gs.id}") do
            assert_text("85%")
            assert_no_text("60%")
        end
        
        sleep(1)
        @gs.reload
        assert_equal 85, @gs.target
    end
    
    test "teacher changes checkpoint action" do
        goal_test_opening
        set_student_goals
        
        assert_equal "Play something kind", @check_2.action
        assert_equal "I will be kind (?) % of the time.", @check_3.action
        
        capybara_login(@teacher_1)
        go_to_goals
        sleep(1)
        within(:css, "#action_span_#{@check_2.id}") do
            assert_no_text("Imagine something kind")
            assert_text("Play something kind")
        end
        
        find("#best_in_place_checkpoint_#{@check_2.id}_action").click.select("Imagine something kind")
    
        within(:css, "#action_span_#{@check_2.id}") do
            assert_text("Imagine something kind")
            assert_no_text("Play something kind")
        end
        
        sleep(1)
        @check_2.reload
        assert_equal "Imagine something kind", @check_2.action
    end
    
    test "teacher changes achievement" do
        goal_test_opening
        set_student_goals
        
        assert_equal nil, @check_2.achievement
        
        capybara_login(@teacher_1)
        go_to_goals
        sleep(1)
        within(:css, "#achievement_span_#{@check_2.id}") do
            assert_text("Achievement")
        end
        
        find("#best_in_place_checkpoint_#{@check_2.id}_achievement").click.select("85%")
        
        within(:css, "#achievement_span_#{@check_2.id}") do
            assert_text("85%")
            assert_no_text("Achievement")
        end
        
        sleep(1)
        @check_2.reload
        assert_equal 85, @check_2.achievement
    end
    
    test "display action includes target" do
        goal_test_opening
        set_student_goals
        
        assert_equal "I will be kind (?) % of the time.", @check_3.action
        
        capybara_login(@teacher_1)
        go_to_goals
        sleep(1)
        within(:css, "#action_span_#{@check_3.id}") do
            assert_text("I will be kind 60 % of the time.")
        end
    end
end