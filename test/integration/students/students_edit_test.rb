require 'test_helper'

class StudentsEditTest < ActionDispatch::IntegrationTest
    
    def setup
       setup_users
       setup_scores
       setup_seminars
    end
    
    def student_edit_stuff
        fill_in "student_first_name", with: "Burgle"
        fill_in "student_last_name", with: "Cut"
        fill_in "student_username", with: "myusername"
        fill_in "student_password", with: "Passy McPasspass"
        fill_in "student_email", with: "my_new_mail@email.com"
        click_on ("Save Changes")
        
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
        go_to_first_period
        click_on("Edit Your Profile")
        assert_no_selector('input', :id => "student_user_number")
        
        student_edit_stuff
    end
    
    test "teacher edits student" do
        capybara_login(@teacher_1)
        click_on("scoresheet_#{@seminar.id}")
        click_on(@student_2.last_name_first)
        click_on("Edit/Move Student")
        assert_selector('input', :id => "student_user_number")
        
        edit_student_user_number
        student_edit_stuff
        check_student_user_number
    end
    
    test "admin edits student" do
        capybara_login(@admin_user)
        click_on("Students Index")
        fill_in "search_field", with: @student_2.id
        choose('Id')
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
        fill_in "search_field", with: @student_2.id
        choose('Id')
        click_button('Search')
        click_on(@student_2.last_name_first)
        
        fill_in "student_username", with: "beersprinkles07"
        click_on ("Save Changes")
        
        assert_equal "mg2", @student_2.username
    end
end