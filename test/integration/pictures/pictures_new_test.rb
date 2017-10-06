require 'test_helper'

class PicturesNewTest < ActionDispatch::IntegrationTest
    
    def setup
        setup_users
        setup_labels
    end
    
    #test "has image attached" do
        #pic = pictures(:cheese_logo)
        #assert File.exists?(pic.image.file.path)
    #end
    
    test "uploads an image" do
        pic = Picture.create(:image => fixture_file_upload('/files/DJ.jpg','image/jpg'), :user => User.first) 
        assert(File.exists?(pic.reload.image.file.path))
    end
    
    test "create new picture" do
        capybara_login(@teacher_1)
        click_on("Upload Pictures")
        fill_in "picture_name", with: "Apple"
        attach_file('picture[image]', Rails.root + 'app/assets/images/apple.png')
        check("check_#{@user_l.id}")
        check("check_#{@admin_l.id}")
        click_on ("Create Picture")
        
        @new_pic = Picture.last
        assert_equal "Apple", @new_pic.name
        assert @new_pic.labels.include?(@user_l)
        assert @new_pic.labels.include?(@admin_l)
        assert @user_l.pictures.include?(@new_pic)
        assert @admin_l.pictures.include?(@new_pic)
        assert @teacher_1, @new_pic.user
        #assert File.exists?(@new_pic.reload.image.file.path)
    end
    
end