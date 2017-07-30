require 'test_helper'

class LabelsIndexTest < ActionDispatch::IntegrationTest
    
    def setup
        @admin     = users(:michael)
        @non_admin = users(:archer)
        setup_labels()
    end
    
    test "index labels as admin" do
        capybara_admin_login()
        click_on("All Labels")

        assert_selector('a', :id => "edit_#{@admin_l.id}", :text => @admin_l.name)
        assert_selector('a', :id => "delete_#{@admin_l.id}", :text => "Delete")
        assert_selector('a', :id => "edit_#{@user_l.id}", :text => @user_l.name)
        assert_selector('a', :id => "delete_#{@user_l.id}", :text => "Delete")
        assert_selector('a', :id => "edit_#{@other_l_pub.id}", :text => @other_l_pub.name)
        assert_selector('a', :id => "delete_#{@other_l_pub.id}", :text => "Delete")
        assert_selector('a', :id => "edit_#{@other_l_priv.id}", :text => @other_l_priv.name)
        assert_selector('a', :id => "delete_#{@other_l_priv.id}", :text => "Delete")
    end
    
    test "index labels as non admin" do
        capybara_teacher_login()
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
        capybara_teacher_login()
        click_on("All Labels")
        assert_selector("h1", :text => "All Labels")
        assert_no_text("Desk-Consultant Facilitator Since:")
        click_on("back_button")
        assert_text("Desk-Consultant Facilitator Since:") 
    end
end