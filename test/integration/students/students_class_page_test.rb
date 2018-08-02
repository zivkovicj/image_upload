require 'test_helper'

class StudentsClassPageTest < ActionDispatch::IntegrationTest
    
    def setup
        setup_users
        setup_schools
        setup_seminars
        setup_goals
        setup_scores
        setup_commodities
    end
    
    test 'teacher updates seminar student' do
        this_gs = @student_2.goal_students.find_by(:seminar => @seminar, :term => 1)
        assert_nil this_gs.goal_id
        
        capybara_login(@teacher_1)
        click_on("scoresheet_#{@seminar.id}")
        click_on(@student_2.last_name_first)
        
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
        gs_term_1.checkpoints.find_by(:sequence => 0).update(:action => gs_term_1.goal.actions[0][2])
        gs_term_1.checkpoints.find_by(:sequence => 1).update(:achievement => 95)
        @student_2.goal_students.find_by(:seminar => @seminar, :term => 2).checkpoints.find_by(:sequence => 2).update(:teacher_comment => "Sup dude!")
        @student_2.goal_students.find_by(:seminar => @seminar, :term => 2).checkpoints.find_by(:sequence => 3).update(:student_comment => "Sup teach!")
        sem_2 = @teacher_1.seminars.second
        
        new_seminar_objective = sem_2.objectives.create(:name => "Flap")
        assert_nil @student_2.objective_students.find_by(:objective => new_seminar_objective)
        
        assert_nil @student_2.goal_students.find_by(:seminar => sem_2)
        
        assert @student_2.seminars.include?(@seminar)
        assert @seminar.students.include?(@student_2)
        assert_not @student_2.seminars.include?(sem_2)
        assert_not sem_2.students.include?(@student_2)
        
        capybara_login(@teacher_1)
        click_on("scoresheet_#{@seminar.id}")
        click_on(@student_2.last_name_first)
        find("#navribbon_move_or_remove").click
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
        
        assert_not_nil @student_2.objective_students.find_by(:objective => new_seminar_objective)
    end
    
    test "remove student from class" do
        capybara_login(@teacher_1)
        click_on("scoresheet_#{@seminar.id}")
        click_on(@student_2.last_name_first)
        find("#navribbon_move_or_remove").click
        find("#delete_#{@seminar.id}").click
        
        @student = @student_2
        click_on("confirm_#{@seminar.id}")
        
        assert_not @seminar.students.include?(@student_2)
        assert_not @student_2.seminars.include?(@seminar)
    end
    
    test "student views seminar student" do
        game_time_ticket = Commodity.find_by(:name => "Game Time Ticket")
        game_time_com_stud = CommodityStudent.find_or_create_by(:user => @student_2, :commodity => game_time_ticket)
        game_time_com_stud.update(:quantity => 3)
        
        fidget_spinner = Commodity.find_by(:name => "Fidget Spinner")
        fidget_com_stud = CommodityStudent.find_or_create_by(:user => @student_2, :commodity => fidget_spinner)
        fidget_com_stud.update(:quantity => 3)
        
        CommodityStudent.where(:user => @student_2, :commodity => @teacher_1_star).update(:quantity => 3)
        go_to_first_period
        
        assert_no_selector('div', :id => "add_buck_increment")  # Counterpart is in "teacher updates seminar student"
        assert_selector('div', :id => "sell_button_#{@teacher_1_star.id}")
        assert_selector('div', :id => "sell_button_#{game_time_ticket.id}")
        assert_no_selector('div', :id => "sell_button_#{fidget_spinner.id}")
        assert_selector('div', :id => "use_button_#{@teacher_1_star.id}")
        assert_no_selector('div', :id => "use_button_#{game_time_ticket.id}")
        assert_no_selector('div', :id => "use_button_#{fidget_spinner.id}")
    end
    
end