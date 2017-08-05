require 'test_helper'

class TeachersEditTest < ActionDispatch::IntegrationTest

    def setup
        setup_users()
        setup_seminars
    end

    test "teacher edits self" do
        assert @teacher_1.authenticate("password")

        capybara_login(@teacher_1)
        click_on("teacher_edit")
        assert_no_text("Teacher Since:")
        
        teacher_editing_stuff(@teacher_1, "Save changes")
        
        assert_text("Teacher Since:")
    end
    
    test "admin edits teacher" do
        capybara_login(@admin_user)
        click_on("Teachers Index")
        click_on(@teacher_1.name_with_title)
        teacher_editing_stuff(@teacher_1, "Save changes")
        
        assert_text("Admin Control Page")
    end

    test "unsuccessful edit" do
        old_name = @teacher_1.first_name
        capybara_login(@teacher_1)
        click_on("teacher_edit")
        
        fill_in "teacher_first_name", with: ""
        click_on("Save changes")
        
        assert_no_text("Teacher Since:")
        @teacher_1.reload
        assert_equal old_name, @teacher_1.first_name
    end

    test "password confirmation" do
        capybara_login(@teacher_1)
        click_on("teacher_edit")
        
        fill_in "teacher_password", with: "bigbigbigbig"
        fill_in "teacher_password_confirmation", with: "what?"
        click_on("Save changes")
        
        assert_no_text("Teacher Since:")
        @teacher_1.reload
        assert @teacher_1.authenticate("password")
    end
    
    test "cannot visit other teacher edit page" do
        capybara_login(@teacher_1)
        visit("/teachers/#{@other_teacher.id}")
        assert_selector('h1', :text => "Log in")
        assert_no_text("Teacher Since:")
    end

  
end