require 'test_helper'

class SessionsHelperTest < ActionView::TestCase
    
    def setup
        setup_users
        setup_schools
        remember(@teacher_1)
    end
    
    test "current_user returns right user" do
        log_in_as @teacher_1
        assert_equal @teacher_1, current_user
        assert is_logged_in?
    end
    
    test "current_user returns nil when remember digest is wrong" do
        @teacher_1.update_attribute(:remember_digest, User.digest(User.new_token))
        assert_nil current_user
    end
    
    test "current_user gives a student when needed" do
        log_in_as @student_1
        assert_not_equal @teacher_1, current_user
        assert_equal @student_1, current_user
        assert is_logged_in?
    end
    
    
end