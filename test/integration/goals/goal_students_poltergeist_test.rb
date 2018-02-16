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
        @gs.update(:goal => Goal.second, :target => 60)
    end
        
    test "teacher changes target" do
        goal_test_opening
        set_student_goals
        
        assert_equal 60, @gs.target
        assert_not @gs.approved
        
        capybara_login(@teacher_1)
        go_to_goals
        sleep(1)
        within(:css, "#target_cell_#{@gs.id}") do
            assert_text("Goal Target: 60 %")
            assert_no_text("Goal Target: 70 %")
        end
        select("70%", :from => "target_select_#{@gs.id}")
        within(:css, "#target_cell_#{@gs.id}") do
            assert_text("Goal Target: 70 %")
            assert_no_text("Goal Target: 60 %")
        end
        
        @gs.reload
        assert @gs.approved
        assert_equal 70, @gs.target
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
        assert @gs.approved
        
        find("#approval_button_#{@gs.id}").click
        within(:css, "#approval_button_#{@gs.id}") do
            assert_text("Lock This Goal")
            assert_no_text("Unlock This Goal")
        end
        @gs.reload
        assert_not @gs.approved
    end
    
    test "teacher changes goal" do
        goal_test_opening
        set_student_goals
        
        assert_not @gs.approved
        
        capybara_login(@teacher_1)
        go_to_goals
        sleep(1)
        within(:css, "#goal_text_#{@gs.id}") do
            assert_no_text("Click to Choose Student's Goal")
            assert_text("Be Kind")
        end
        bip_select(@gs, :goal_id, Goal.first.name)
        select("#{Goal.first.name}", :from => "goal_select_#{@gs.id}")
        within(:css, "#goal_text_#{@gs.id}") do
            assert_text("Be Awesome 24/7")
            assert_no_text("Be Kind")
        end
        
        select("70%", :from => "target_select_#{@gs.id}")
        within(:css, "#target_cell_#{@gs.id}") do
            assert_text("Goal Target: 70 %")
            assert_no_text("Goal Target: 60 %")
        end
        
        @gs.reload
        assert @gs.approved
        assert_equal 70, @gs.target
        
        @gs.reload
        assert @gs.approved
        assert_equal Goal.first, @gs.goal
        assert_equal "Play something awesome", @gs.checkpoints[0].action
        assert_equal "Be halfway awesome", @gs.checkpoints[1].action
        assert_equal "Play something awesome", @gs.checkpoints[2].action
        assert_equal "I will be awesome for (?)% of the school days this term.", @gs.checkpoints[3].action
        assert_equal "I will be awesome for 60% of the school days this term.", @gs.checkpoints[3].statement
        
    end
        
end