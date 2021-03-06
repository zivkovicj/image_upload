require 'test_helper'

class LabelsFormTest < ActionDispatch::IntegrationTest
    
    def setup
        setup_users
        setup_schools
        setup_labels
        setup_questions
        @new_name = "20.1 One-step equations with diagrams"
    end
    
    def go_to_all_labels
        click_on("View/Create Content")
        click_on("All Labels")
    end
    
    def go_to_new_label
        click_on("View/Create Content")
        click_on("Create a New Label")
    end
    
    test "create new label" do
        old_label_count = Label.count
        
        capybara_login(@teacher_1)
        go_to_new_label
        
        fill_in "name", with: @new_name
        click_on("Create This Label")
        
        assert_equal old_label_count + 1, Label.count
        @new_label = Label.last
        assert_equal @new_name, @new_label.name
        assert_equal "private", @new_label.extent
        assert_equal @teacher_1, @new_label.user
        
        @user_q.reload
        
        # Need to assert redirection soon
    end
    
     test "admin creates label" do
        capybara_login(@admin_user)
        go_to_new_label
        
        fill_in "name", with: @new_name
        choose("public_label")
        click_on("Create This Label")
        
        @new_label = Label.last
        assert_equal @new_name, @new_label.name
        assert_equal "public", @new_label.extent
        assert_equal @admin_user, @new_label.user

        # Need to assert redirection soon
    end
    
    test "invalid label" do
        capybara_login(@teacher_1)
        go_to_new_label
        
        # No name entered
        click_on("Create This Label")
        
        assert_selector('h2', :text => "New Label")
        assert_selector('div', :id => "error_explanation")
        assert_selector('li', :text => "Name can't be blank")
    end
    
    test "view other teacher label" do
        capybara_login(@teacher_1)
        go_to_all_labels
        click_on(@other_l_pub.name)
        
        assert_text("You are viewing the details of this label. You may not make any edits because it was created by another teacher.")
        assert_no_selector('textarea', :id => "name", :visible => true)
        assert_no_text("Save Changes")
        
    end
    
    test "edit admin label" do
        capybara_login(@teacher_1)
        go_to_all_labels
        click_on(@admin_l.name)
        
        assert_text("You are viewing the details of this label. You may not make any edits because it was created by another teacher.")
        assert_no_selector('textarea', :id => "name", :visible => true)
    end
    
    test "edit own label" do
        new_name = "New name for this label"
        assert_not_equal new_name, @user_l.name
        
        capybara_login(@teacher_1)
        go_to_all_labels
        click_on(@user_l.name)
        
        assert_no_text("You may only edit a label that you have created.")
        
        fill_in "name", with: new_name
        click_on("Save Changes")
        
        @user_l.reload
        assert_equal new_name, @user_l.name
    end
end