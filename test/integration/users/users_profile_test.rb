require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
    
    include ApplicationHelper
    
    def setup
        @admin_user = users(:michael)
        @user = users(:archer)
        @wrong_user = users(:zacky)
    end
    
    test "profile display" do
        log_in_as @user
        get user_path(@user)
        assert_template 'users/show'
        assert_select 'title', full_title(@user.nameWithTitle)
        #assert_select 'h1>img.gravatar'
        assert_match @user.own_seminars.count.to_s, response.body
        @user.own_seminars.each do |seminar|
            assert_match seminar.name, response.body
        end
    end
    
    test "Redirect for incorrect user" do
         log_in_as @wrong_user
         get user_path(@user)
         assert_redirected_to login_url
    end
    
    test "But admin user is okay." do
        log_in_as @admin_user
        get user_path(@user)
        assert_template 'users/show'
    end
end
