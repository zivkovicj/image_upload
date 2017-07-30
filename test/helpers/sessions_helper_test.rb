require 'test_helper'

class SessionsHelperTest < ActionView::TestCase
    
    def setup
        @user = users(:michael)
        @teacher_user = users(:archer)
        @student = students(:student_1)
        remember(@user)
    end
    
    test "current_user returns right user" do
        log_in_as @teacher_user
        assert_equal @teacher_user, current_user
        assert is_logged_in?
    end
    
    test "current_user returns nil when remember digest is wrong" do
        @user.update_attribute(:remember_digest, User.digest(User.new_token))
        assert_nil current_user
    end
    
    test "current_user gives a student when needed" do
        log_in_as @student
        assert_not_equal @user, current_user
        assert_equal @student, current_user
        assert is_logged_in?
    end
    
    
end