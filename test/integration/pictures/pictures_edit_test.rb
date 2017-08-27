require 'test_helper'

class PicturesEditTest < ActionDispatch::IntegrationTest
    
    def setup
        setup_users
        setup_pictures
        setup_labels
        
    end
    
    test "edit picture" do
        assert_not @user_p.labels.include?(@admin_l)
        assert @user_p.labels.include?(@user_l)
        
        capybara_login(@teacher_1)
        click_on('All Pictures')
        click_on("edit_#{@user_p.id}")
        
        fill_in "picture_name", with: "Beer and Pretzels"
        check("check_#{@admin_l.id}")
        uncheck("check_#{@user_l.id}")
        attach_file('picture[image]', Rails.root + 'app/assets/images/logo.png')
        click_on("Update Picture")
        
        @user_p.reload
        assert_equal "Beer and Pretzels", @user_p.name
        assert @user_p.labels.include?(@admin_l)
        assert_not @user_p.labels.include?(@user_l)
        assert @admin_l.pictures.include?(@user_p)
        assert_not @user_l.pictures.include?(@user_p)
        # assert_not_equal old_pic, @user_p.image
        # Learn how to test this some day
    end
    
end