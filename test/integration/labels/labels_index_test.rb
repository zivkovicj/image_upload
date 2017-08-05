require 'test_helper'

class LabelsIndexTest < ActionDispatch::IntegrationTest
    
    def setup
        setup_users()
        setup_labels()
        @old_label_count = Label.count
    end
    
    test "index labels as admin" do
        capybara_login(@admin_user)
        click_on("All Labels")

        assert_selector('a', :id => "edit_#{@admin_l.id}", :text => @admin_l.name)
        assert_selector('a', :id => "delete_#{@admin_l.id}", :text => "Delete")
        assert_selector('a', :id => "edit_#{@user_l.id}", :text => @user_l.name)
        assert_selector('a', :id => "delete_#{@user_l.id}", :text => "Delete")
        assert_selector('a', :id => "edit_#{@other_l_pub.id}", :text => @other_l_pub.name)
        assert_selector('a', :id => "delete_#{@other_l_pub.id}", :text => "Delete")
        assert_selector('a', :id => "edit_#{@other_l_priv.id}", :text => @other_l_priv.name)
        assert_selector('a', :id => "delete_#{@other_l_priv.id}", :text => "Delete")
        
        click_on("delete_#{@admin_l.id}")
        assert @old_label_count - 1, Label.count
    end
    
    test "index labels as non admin" do
        capybara_login(@teacher_1)
        click_on("All Labels")
    
        assert_selector('a', :id => "edit_#{@admin_l.id}", :text => @admin_l.name)
        assert_selector('a', :id => "delete_#{@admin_l.id}", :text => "Delete", :count => 0)
        assert_selector('a', :id => "edit_#{@user_l.id}", :text => @user_l.name)
        assert_selector('a', :id => "delete_#{@user_l.id}", :text => "Delete")
        assert_selector('a', :id => "edit_#{@other_l_pub.id}", :text => @other_l_pub.name)
        assert_selector('a', :id => "delete_#{@other_l_pub.id}", :text => "Delete",:count => 0)
        assert_selector('a', :id => "edit_#{@other_l_priv.id}", :text => @other_l_priv.name, :count => 0)
        assert_selector('a', :id => "delete_#{@other_l_priv.id}", :text => "Delete", :count => 0)
    end
    
    test "back button" do
        capybara_login(@teacher_1)
        click_on("All Labels")
        assert_selector("h1", :text => "All Labels")
        assert_not_on_teacher_page
        click_on("back_button")
        assert_on_teacher_page
    end
end