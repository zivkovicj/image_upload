require 'test_helper'

class StudentsEditTest < ActionDispatch::IntegrationTest
    
    def setup
       setup_users
       setup_objectives
       setup_seminars
       setup_goals
    end
    
    def student_edit_stuff
        fill_in "student_first_name", with: "Burgle"
        fill_in "student_last_name", with: "Cut"
        fill_in "student_username", with: "myusername"
        fill_in "student_password", with: "Passy McPasspass"
        fill_in "student_email", with: "my_new_mail@email.com"
        click_on("Save Changes")
        
        @student_2.reload
        assert_equal "Burgle", @student_2.first_name
        assert_equal "Cut", @student_2.last_name
        assert_equal "myusername", @student_2.username
        assert @student_2.authenticate("Passy McPasspass")
        assert_equal "my_new_mail@email.com", @student_2.email
    end
    
    def edit_student_user_number
        fill_in "student_user_number", with: 1073514
    end
    
    def check_student_user_number
        assert_equal 1073514, @student_2.user_number 
    end
    
    test "student edits self" do
        skip
        go_to_first_period
        click_on("Edit Your Profile")
        assert_no_selector('input', :id => "student_user_number")
        student_edit_stuff
    end
    
    test "teacher edits student" do
        setup_scores
        
        capybara_login(@teacher_1)
        click_on("scoresheet_#{@seminar.id}")
        click_on(@student_2.last_name_first)
        click_on("Edit/Move Student")
        assert_selector('input', :id => "student_user_number")
        
        edit_student_user_number
        student_edit_stuff
        check_student_user_number
    end
    
    test "give quiz keys" do
        poltergeist_stuff
        setup_scores
        
        @test_os = @objective_10.objective_students.find_by(:user => @student_2)
        @test_os.update(:teacher_granted_keys => 2, :points => 2)
        mainassign_os = @objective_20.objective_students.find_by(:user => @student_2)

        capybara_login(@teacher_1)
        click_on("scoresheet_#{@seminar.id}")
        click_on(@student_2.last_name_first)
        
        assert_no_selector('div', :id => "not_ready_#{@test_os.id}")
        assert_selector('div', :id => "not_ready_#{mainassign_os.id}")
        
        this_holder = ".key_holder_#{@test_os.id}"
        within(this_holder) do
            assert_selector('img', :count => 2) 
        end
    
        find(".add_key_2_#{@test_os.id}").click
        
        within(this_holder) do
            assert_selector('img', :count => 4) 
        end
        
        sleep(1)
        @test_os.reload
        assert_equal 4, @test_os.teacher_granted_keys
        
        find(".add_key_1_#{@test_os.id}").click
        
        within(this_holder) do
            assert_selector('img', :count => 5) 
        end
        
        sleep(1)
        @test_os.reload
        assert_equal 5, @test_os.teacher_granted_keys
        
        find(this_holder).click
        
        within(this_holder) do
            assert_selector('img', :count => 4) 
        end
        
        assert_selector('div', :count => 4)
        
        @test_os.reload
        assert_equal 4, @test_os.teacher_granted_keys
    end
    
    test "admin edits student" do
        capybara_login(@admin_user)
        click_on("Students Index")
        fill_in "search_field", with: @student_2.user_number
        choose("Student number")
        click_button('Search')
        click_on(@student_2.last_name_first)
        assert_selector('input', :id => "student_user_number")
        
        edit_student_user_number
        student_edit_stuff
        check_student_user_number
    end
    
    test "edit username to already taken" do
        @student_1.update(:username => "beersprinkles07")
        capybara_login(@admin_user)
        click_on("Students Index")
        fill_in "search_field", with: @student_2.user_number
        choose('Student number')
        click_button('Search')
        click_on(@student_2.last_name_first)
        
        fill_in "student_username", with: "beersprinkles07"
        click_on("Save Changes")
        
        assert_equal "mg2", @student_2.username
    end
end