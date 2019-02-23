require 'test_helper'

class PicturesEditTest < ActionDispatch::IntegrationTest
    
    def setup
        setup_users
        setup_schools
        setup_pictures
        setup_labels
        @old_picture_count = Picture.count
    end
    
    def goto_user_pic_edit
        capybara_login(@teacher_1)
        click_on("View/Create Content")
        click_on('All Pictures')
        click_on("edit_#{@user_p.id}")
    end
    
    test "edit picture" do
        assert_not @user_p.labels.include?(@admin_l)
        assert @user_p.labels.include?(@user_l)
        #old_image = @user_p.image
        
        goto_user_pic_edit
        fill_in "picture_name", with: "Beer and Pretzels"
        check("check_#{@admin_l.id}")
        uncheck("check_#{@user_l.id}")
        attach_file('picture[image]', Rails.root + 'app/assets/images/apple.jpg')
        click_on("Update Picture")
        
        @user_p.reload
        assert_equal "Beer and Pretzels", @user_p.name
        assert @user_p.labels.include?(@admin_l)
        assert_not @user_p.labels.include?(@user_l)
        assert @admin_l.pictures.include?(@user_p)
        assert_not @user_l.pictures.include?(@user_p)
        #assert_not_equal old_image, @user_p.image
        
        assert_selector('p', :text => "Teacher Since:")
        
    end
    
    test "default picture name edit" do
        old_name = @user_p.name
        goto_user_pic_edit
        fill_in "picture_name", with: ""
        attach_file('picture[image]', Rails.root + 'app/assets/images/apple.jpg')
        click_on ("Update Picture")
        
        @user_p.reload
        assert_equal old_name, @user_p.name
        assert_selector('li', :text => "Name can't be blank")
    end
    
    test "no picture edit" do
        goto_user_pic_edit
        fill_in "picture_name", with: "Snorble"
        click_on ("Update Picture")
        
        # In the future, find out how to test if the actual image was changed.
        # Right now, the image stays the same if the user doesn't upload a new file.
        # That's the desired behavior, but I can't test it.
        assert_selector('p', :text => "Teacher Since:")
        @user_p.reload
        assert_equal "Snorble", @user_p.name
    end
    
end