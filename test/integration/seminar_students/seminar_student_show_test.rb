require 'test_helper'

class SeminarStudentsShowTest < ActionDispatch::IntegrationTest
    
    def setup
        setup_users
        setup_schools
        setup_seminars
        setup_goals
        setup_scores
        setup_commodities
    end
    
    def button_not_present(id)
        assert_no_selector('div', :id => id) 
    end
    
    def element_present_and_showing(id)
        assert_selector('div', :id => id)
        assert_no_selector('div', :id => id, :class => "currently_hidden") 
    end
    
    def element_present_and_hidden(id)
        assert_selector('div', :id => id)
        assert_selector('div', :id => id, :class => "currently_hidden") 
    end
    
    def check_visibility_use_and_sell_buttons
        # Sell Buttons
        element_present_and_showing("sell_button_#{@teacher_1_star.id}")
        element_present_and_showing("sell_button_#{@game_time_ticket.id}")
        button_not_present("sell_button_#{@fidget_spinner.id}")  # Fidget Spinner is not salable
        element_present_and_hidden("sell_button_#{@piece_of_candy.id}")
        
        # Use Buttons
        element_present_and_showing("use_button_#{@teacher_1_star.id}")
        button_not_present("use_button_#{@game_time_ticket.id}")  # Game ticket is salable, but not usable
        button_not_present("use_button_#{@fidget_spinner.id}")      # Fidget spinner not salable or usable
        element_present_and_hidden("use_button_#{@piece_of_candy.id}")
    end
    
    def give_student(commode)
        @game_time_com_stud = CommodityStudent
            .create(:user => @student_2, :commodity => commode, :quantity => 1)
    end
    
    def give_student_100_bucks
        @student_2.currencies.create(:seminar => @seminar, :value => 100)
    end
    
    def give_student_ticket_and_star
        give_student(@game_time_ticket)
        give_student(@teacher_1_star)
    end
    
    test 'grades back button' do
        capybara_login(@student_2)
        click_on("1st Period")
        click_on("Objectives")
    end
    
    test 'objective downloading screen' do
        setup_objectives
        setup_worksheets
        
        capybara_login(@student_2)
        click_on("1st Period")
        click_on("Objectives")
        
        assert_selector("h3", :text => "Stars This Term")
        assert_selector("a", :text => @own_assign.name)
        assert_no_selector("a", :text => @objective_10.name)
        assert_selector("td", :text => @objective_10.name)
        
        # Check that student can link to download files for an objective, but not change them.
        click_link("link_to_#{@own_assign.id}")
        
        assert_no_selector("h5", :text => "1st Period")
        assert_selector("h2", :text => "for #{@own_assign.name}")
        assert_selector("h2", :text => "Current Files")
        assert_no_selector("h3", :text => "Upload a New File")  #Counterpart is in objectives_edit_test
        
        # Back to class screen
        click_on("Back to 1st Period")
        
        assert_no_selector("h2", :text => "Current Files")
        assert_selector("h5", :text => "1st Period")
    end
    
    test 'teacher updates seminar student' do
        skip
        this_gs = @student_2.goal_students.find_by(:seminar => @seminar, :term => 1)
        assert_nil this_gs.goal_id
        
        capybara_login(@teacher_1)
        click_on("scoresheet_seminar_#{@seminar.id}")
        click_on(@student_2.last_name_first)
        
        click_on("Market")
        assert_selector('div', :id => "add_buck_increment")
        
        click_on("Edit This Goal")
        select("#{Goal.first.name}", :from => 'goal_student_goal_id')
        select("65%", :from => 'goal_student_target')
        click_on("Save This Goal")
        
        this_gs.reload
        assert_equal Goal.first.id, this_gs.goal_id
        assert_equal 65, this_gs.target
    end
    
     test "move student to different class" do
        gs_term_1 = @student_2.goal_students.find_by(:seminar => @seminar, :term => 1)
        gs_term_1.update(:goal => Goal.second)
        gs_term_1.checkpoints.find_by(:sequence => 1).update(:action => gs_term_1.goal.actions[1][2])
        gs_term_1.checkpoints.find_by(:sequence => 2).update(:achievement => 95)
        @student_2.goal_students.find_by(:seminar => @seminar, :term => 2).checkpoints.find_by(:sequence => 3).update(:teacher_comment => "Sup dude!")
        @student_2.goal_students.find_by(:seminar => @seminar, :term => 2).checkpoints.find_by(:sequence => 4).update(:student_comment => "Sup teach!")
        sem_2 = @teacher_1.seminars.second
        
        new_seminar_objective = sem_2.objectives.create(:name => "Flap")
        assert_nil @student_2.objective_students.find_by(:objective => new_seminar_objective)
        
        assert_nil @student_2.goal_students.find_by(:seminar => sem_2)
        
        assert @student_2.seminars.include?(@seminar)
        assert @seminar.students.include?(@student_2)
        assert_not @student_2.seminars.include?(sem_2)
        assert_not sem_2.students.include?(@student_2)
        assert_nil SeminarStudent.find_by(:user => @student_2, :seminar => sem_2)
        
        capybara_login(@teacher_1)
        click_on("scoresheet_seminar_#{@seminar.id}")
        click_on(@student_2.last_name_first)
        click_on("Move or Remove")
        click_on("Move to #{sem_2.name}")
        
        @student_2.reload
        sem_2.reload
        assert_not @student_2.seminars.include?(@seminar)
        assert_not @seminar.students.include?(@student_2)
        assert @student_2.seminars.include?(sem_2)
        assert sem_2.students.include?(@student_2)
        newest_sem_stud = SeminarStudent.find_by(:user => @student_2, :seminar => sem_2)
        assert_equal Date.today, newest_sem_stud.last_consultant_day
        
        new_gs_1 = @student_2.goal_students.find_by(:seminar => sem_2, :term => 1)
        new_gs_2 = @student_2.goal_students.find_by(:seminar => sem_2, :term => 2)
        
        assert_equal Goal.second, new_gs_1.goal
        assert_nil new_gs_2.goal
        
        assert_equal Goal.second.actions[1][2], new_gs_1.checkpoints.find_by(:sequence => 1).action
        assert_equal 95, new_gs_1.checkpoints.find_by(:sequence => 2).achievement
        assert_equal "Sup dude!", new_gs_2.checkpoints.find_by(:sequence => 3).teacher_comment
        assert_equal "Sup teach!", new_gs_2.checkpoints.find_by(:sequence => 4).student_comment
        
        assert_nil new_gs_2.checkpoints.find_by(:sequence => 1).action
        assert_nil new_gs_2.checkpoints.find_by(:sequence => 2).achievement
        assert_nil new_gs_1.checkpoints.find_by(:sequence => 3).teacher_comment
        assert_nil new_gs_1.checkpoints.find_by(:sequence => 4).student_comment
        
        assert_not_nil @student_2.objective_students.find_by(:objective => new_seminar_objective)
    end
    
    test "remove student from class" do
        capybara_login(@teacher_1)
        click_on("scoresheet_seminar_#{@seminar.id}")
        click_on(@student_2.last_name_first)
        click_on("Move or Remove")
        find("#delete_#{@seminar.id}").click
        
        @student = @student_2
        click_on("confirm_#{@seminar.id}")
        
        assert_not @seminar.students.include?(@student_2)
        assert_not @student_2.seminars.include?(@seminar)
    end
    
    test "market for student with bucks" do
        give_student_ticket_and_star
        give_student_100_bucks
        
        go_to_first_period
        
        button_not_present("add_buck_increment")
        click_on("Market")
        
        # Buy button showing.  Others are not.
        element_present_and_showing("buy_button_#{@game_time_ticket.id}")
        element_present_and_hidden("cannot_buy_#{@game_time_ticket.id}")
        element_present_and_hidden("unstocked_#{@game_time_ticket.id}")
        
        check_visibility_use_and_sell_buttons
    end
    
    test "market for student without bucks" do
        give_student_ticket_and_star
        
        # Don't give student any currency
        
        go_to_first_period
        
        click_on("Market")
        button_not_present("add_buck_increment")
        
        # Can't afford showing.
        element_present_and_hidden("buy_button_#{@game_time_ticket.id}")
        element_present_and_showing("cannot_buy_#{@game_time_ticket.id}")
        element_present_and_hidden("unstocked_#{@game_time_ticket.id}")
        
        check_visibility_use_and_sell_buttons
    end
    
    test "market if tickets unstocked" do
        give_student_ticket_and_star
        give_student_100_bucks
        
        # Set stock of game tickets to zero
        @game_time_ticket.update(:quantity => 0)
        
        go_to_first_period
        click_on("Market")
        
        # Buy button showing.  Others are not.
        element_present_and_hidden("buy_button_#{@game_time_ticket.id}")
        element_present_and_hidden("cannot_buy_#{@game_time_ticket.id}")
        element_present_and_showing("unstocked_#{@game_time_ticket.id}")
        
        check_visibility_use_and_sell_buttons
    end
    
    test "market for teacher" do
        give_student_ticket_and_star
        
        capybara_login(@teacher_1)
        click_on("scoresheet_seminar_#{@seminar.id}")
        click_on(@student_2.last_name_first)
        click_on("Market")
        
        # Button to Add Bucks DOES Show for Teacher
        element_present_and_showing("add_buck_increment")
        
        check_visibility_use_and_sell_buttons
    end
    
end