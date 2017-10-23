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
        
        assert_selector('h5', :id => "delete_#{@user_p.id}")
        assert_no_selector('h5', :id => "delete_#{@admin_p.id}")
        assert_no_selector('h5', :id => "delete_#{@other_p.id}")
    end
    
    test "index for admin" do
        capybara_login(@admin_user) 
        click_on("All Pictures")
       
        assert_selector('a', :id => "edit_#{@user_p.id}")
        assert_selector('a', :id => "edit_#{@admin_p.id}")
        assert_selector('a', :id => "edit_#{@other_p.id}")
    
        assert_selector('h5', :id => "delete_#{@user_p.id}")
        assert_selector('h5', :id => "delete_#{@admin_p.id}")
        assert_selector('h5', :id => "delete_#{@other_p.id}")
    end
    
    test "delete picture" do
        setup_questions
        
        old_pic_count = Picture.count
        first_quest = @admin_p.questions.first
        assert_not_nil first_quest
        first_lab = @admin_p.labels.first
        first_lab_pic_count = first_lab.pictures.count
        
        capybara_login(@admin_user) 
        click_on("All Pictures")
        
        find("#delete_#{@admin_p.id}").click
        click_on("confirm_#{@admin_p.id}")
        
        first_quest.reload
        first_lab.reload
        assert_equal old_pic_count - 1, Picture.count
        assert_nil first_quest.picture_id
        assert_equal first_lab_pic_count - 1, first_lab.pictures.count
    end
    
end