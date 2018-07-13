require 'test_helper'

class AdminsEditTest < ActionDispatch::IntegrationTest

    def setup
        setup_users
    end

    test "admin edits self" do
        assert @admin_user.authenticate("password")

        capybara_login(@admin_user)
        click_on("teacher_edit")
        assert_no_text("Admin Control Page")
        
        select('Mrs.', :from => 'admin_title')
        fill_in "admin_first_name", with: "Spangle"
        fill_in "admin_last_name", with: "Bot"
        fill_in "admin_email", with: "Spangle@Bot.com"
        fill_in "admin_password", with: "adminadminadmin"
        fill_in "admin_password_confirmation", with: "adminadminadmin"
        click_on("Save Changes")
      
        @admin_user.reload
        assert_equal "Mrs.", @admin_user.title
        assert_equal "Spangle", @admin_user.first_name
        assert_equal "Bot", @admin_user.last_name
        assert_equal "spangle@bot.com", @admin_user.email
        assert @admin_user.authenticate("adminadminadmin")
        
        assert_text("Admin Control Page")
    end
    
    test "invalid info" do
        assert @admin_user.authenticate("password")
        old_title = @admin_user.title
        old_first_name = @admin_user.first_name
        old_last_name = @admin_user.last_name
        old_email = @admin_user.email

        capybara_login(@admin_user)
        click_on("teacher_edit")
        
        select('Mrs.', :from => 'admin_title')
        fill_in "admin_first_name", with: "Spangle"
        fill_in "admin_last_name", with: " "
        click_on("Save Changes")
      
        @admin_user.reload
        assert_equal old_title, @admin_user.title
        assert_equal old_first_name, @admin_user.first_name
        assert_equal old_last_name, @admin_user.last_name
        assert_equal old_email, @admin_user.email
        assert @admin_user.authenticate("password")
        
        assert_selector('h2', :text => "Update Your Admin Profile")
        assert_selector('div', :id => "error_explanation")
        assert_selector('li', :text => "Last name can't be blank")
    end
end