require 'test_helper'

class PicturesIndexTest < ActionDispatch::IntegrationTest
    
    def setup
        setup_users
        setup_pictures
    end
    
    test "index for archer" do
        capybara_login(@teacher_1)
        click_on("All Pictures")
        
        assert_selector('a', :id => "edit_#{@user_p.id}")
        assert_no_selector('a', :id => "edit_#{@admin_p.id}")
        assert_no_selector('a', :id => "edit_#{@other_p.id}")
        
        assert_selector('a', :id => "delete_#{@user_p.id}")
        assert_no_selector('a', :id => "delete_#{@admin_p.id}")
        assert_no_selector('a', :id => "delete_#{@other_p.id}")
    end
    
    test "index for admin" do
        capybara_login(@admin_user) 
        click_on("All Pictures")
       
        assert_selector('a', :id => "edit_#{@user_p.id}")
        assert_selector('a', :id => "edit_#{@admin_p.id}")
        assert_selector('a', :id => "edit_#{@other_p.id}")
    
        assert_selector('a', :id => "delete_#{@user_p.id}")
        assert_selector('a', :id => "delete_#{@admin_p.id}")
        assert_selector('a', :id => "delete_#{@other_p.id}")
    end
    
end