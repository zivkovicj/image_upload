require 'test_helper'

class LabelsFormTest < ActionDispatch::IntegrationTest
    
    def setup
        setup_users()
        setup_labels()
        setup_questions()
        @new_name = "20.1 One-step equations with diagrams"
    end
    
    test "create new label" do
        oldLabelCount = Label.count
        @user_q.update(:label => @user_l)
        
        capybara_login(@teacher_1)
        click_on("Create a New Label")
        
        @user_q.reload
        assert_equal @user_l, @user_q.label 
        
        fill_in "name", with: @new_name
        check("question_#{@user_q.id}")
        click_on("Create This Label")
        
        assert_equal oldLabelCount + 1, Label.count
        @new_label = Label.last
        assert_equal @new_name, @new_label.name
        assert_equal "public", @new_label.extent
        assert_equal @teacher_1, @new_label.user
        
        @user_q.reload
        assert @new_label.questions.include?(@user_q)
        assert_not_equal @user_l, @user_q.label
        assert_equal @new_label, @user_q.label
        
        # Need to assert redirection soon
    end
    
     test "admin creates label" do
        capybara_login(@admin_user)
        click_on("Create a New Label")
        
        fill_in "name", with: @new_name
        click_on("Create This Label")
        
        @new_label = Label.last
        assert_equal @new_name, @new_label.name
        assert_equal "public", @new_label.extent
        assert_equal @admin_user, @new_label.user

        # Need to assert redirection soon
    end
    
    test "invalid label" do
        capybara_login(@teacher_1)
        click_on("Create a New Label")
        
        # No name entered
        click_on("Create This Label")
        
        assert_selector('h1', :text => "New Label")
        assert_selector('div', :id => "error_explanation")
        assert_selector('li', :text => "Name can't be blank")
    end
    
    test "edit other teacher label" do
        capybara_login(@teacher_1)
        click_on('All Labels')
        click_on(@other_l_pub.name)
        
        assert_text("You may only edit a label that you have created.")
        assert_no_selector('textarea', :id => "name", :visible => true)
    end
    
    test "edit admin label" do
        capybara_login(@teacher_1)
        click_on('All Labels')
        click_on(@admin_l.name)
        
        assert_text("You may only edit a label that you have created.")
        assert_no_selector('textarea', :id => "name", :visible => true)
    end
    
    test "edit own label" do
        new_name = "New name for this label"
        assert_not_equal new_name, @user_l.name
        
        capybara_login(@teacher_1)
        click_on('All Labels')
        click_on(@user_l.name)
        
        assert_no_text("You may only edit a label that you have created.")
        
        fill_in "name", with: new_name
        click_on("Save Changes")
        
        @user_l.reload
        assert_equal new_name, @user_l.name
    end
    
    test "user presence of question checkboxes" do
        capybara_login(@teacher_1)
        click_on("Create a New Label")
        
        assert_no_selector("input", :id => "question_#{@admin_q.id}")
        assert_selector("input", :id => "question_#{@user_q.id}")
        assert_no_selector("input", :id => "question_#{@other_q_pub.id}")
        assert_no_selector("input", :id => "question_#{@other_q_priv.id}")
    end
    
    test "admin presence of question checkboxes" do
        capybara_login(@admin_user)
        click_on("Create a New Label")
        
        assert_selector("input", :id => "question_#{@admin_q.id}")
        assert_selector("input", :id => "question_#{@user_q.id}")
        assert_selector("input", :id => "question_#{@other_q_pub.id}")
        assert_selector("input", :id => "question_#{@other_q_priv.id}")        
    end
end