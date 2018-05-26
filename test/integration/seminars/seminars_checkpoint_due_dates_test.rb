require 'test_helper'

class SeminarsCheckpointDueDatesTest < ActionDispatch::IntegrationTest
    
    def setup
        setup_users
        setup_seminars
        
        @array_should_be = 
            [["01/11/2018", "01/12/2018", "01/13/2018", "01/14/2018"],
            ["01/15/2018","01/16/2018","01/17/2018","01/18/2018"],
            ["01/19/2018","01/20/2018","01/21/2018","01/22/2018"],
            ["01/23/2018","01/24/2018",nil,"01/26/2018"]]
    end
    
    test "edit checkpoint due dates" do
        capybara_login(@teacher_1)
        click_on("edit_seminar_#{@seminar.id}")
        
        fill_in "seminar[checkpoint_due_dates][0][0]", with: "01/11/2018"
        fill_in "seminar[checkpoint_due_dates][0][1]", with: "01/12/2018"
        fill_in "seminar[checkpoint_due_dates][0][2]", with: "01/13/2018"
        fill_in "seminar[checkpoint_due_dates][0][3]", with: "01/14/2018"
        fill_in "seminar[checkpoint_due_dates][1][0]", with: "01/15/2018"
        fill_in "seminar[checkpoint_due_dates][1][1]", with: "01/16/2018"
        fill_in "seminar[checkpoint_due_dates][1][2]", with: "01/17/2018"
        fill_in "seminar[checkpoint_due_dates][1][3]", with: "01/18/2018"
        fill_in "seminar[checkpoint_due_dates][2][0]", with: "01/19/2018"
        fill_in "seminar[checkpoint_due_dates][2][1]", with: "01/20/2018"
        fill_in "seminar[checkpoint_due_dates][2][2]", with: "01/21/2018"
        fill_in "seminar[checkpoint_due_dates][2][3]", with: "01/22/2018"
        fill_in "seminar[checkpoint_due_dates][3][0]", with: "01/23/2018"
        fill_in "seminar[checkpoint_due_dates][3][1]", with: "01/24/2018"
        # [3][2] left out for testing
        fill_in "seminar[checkpoint_due_dates][3][3]", with: "01/26/2018"
        
        click_on("Update This Class")
        
        @seminar.reload
        this_array_should_be =
            [["01/11/2018", "01/12/2018", "01/13/2018", "01/14/2018"],
            ["01/15/2018", "01/16/2018", "01/17/2018", "01/18/2018"],
            ["01/19/2018", "01/20/2018", "01/21/2018", "01/22/2018"],
            ["01/23/2018", "01/24/2018", "04/21/2018", "01/26/2018"]]  # [3][3] is different because it's leftover fromm the beginning array.
        assert_equal this_array_should_be, @seminar.checkpoint_due_dates
    end
    
    test "student cant edit old checkpoints" do
        setup_scores
        setup_goals
        travel_to Time.zone.local(2018, 04, 13, 01, 04, 44)
        @seminar.update(:term => 3) # To test for an error on the nil due date
        
        go_to_first_period
        click_on("Edit This Goal")
        select("#{Goal.second.name}", :from => 'goal_student_goal_id')
        select("60%", :from => 'goal_student_target')
        click_on("Save This Goal")
        
        assert_selector('h5', :id => "past_due_0")  # Past the due date
        assert_no_selector('div', :id => "action_picker_0")
        
        assert_selector('h5', :id => "too_soon_1")
        assert_no_selector('div', :id => "action_picker_1")  # Too close to due date
        
        assert_selector('div', :id => "action_picker_2")  # Should show
        
        assert_no_selector('div', :id => "action_picker_3")  # Doesn't show because there's only one choice.
    end
    
    test "copy due dates" do
        first_seminar = @teacher_1.first_seminar
        first_seminar.update(:checkpoint_due_dates => @array_should_be)
        second_seminar = @teacher_1.seminars.second
        assert_not_equal @array_should_be, second_seminar.checkpoint_due_dates
        
        capybara_login(@teacher_1)
        click_on("edit_seminar_#{second_seminar.id}")
        click_on("Copy Due Dates from #{first_seminar.name}")
        
        assert_selector("h1", :text => "Edit #{second_seminar.name}")
        second_seminar.reload
        assert_equal @array_should_be, second_seminar.checkpoint_due_dates
    end
    
    test "no copy button for same class" do
        first_seminar = @teacher_1.first_seminar
        
        capybara_login(@teacher_1)
        click_on("edit_seminar_#{first_seminar.id}")
        assert_no_text("Copy Due Dates from #{first_seminar.name}")
    end
end