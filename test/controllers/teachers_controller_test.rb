require 'test_helper'

class TeachersControllerTest < ActionDispatch::IntegrationTest
   
    def setup
        setup_users
    end
    
    test "controller edit wrong user" do
        log_in_as(@teacher_1)
        patch teacher_path(@other_teacher), params: { teacher: { first_name:  "Valid",
                                              last_name: "Valid",
                                              email: "e@mail.com",
                                              password:              "valid",
                                              password_confirmation: "valid" } }
        assert_redirected_to login_path
        assert_not_equal "Valid", @other_teacher.first_name
    end
end