require 'test_helper'

class StudentsControllerTest < ActionDispatch::IntegrationTest
    
    def setup
        setup_users
        setup_schools
        setup_seminars
    end
    
    test "students index test as admin" do
        # The test for logging in a capybra test in the integration folder.
        log_in_as(@admin_user)
        get students_path
        assert_template 'students/index'
    end
    
    test "students index test as student" do
        # The test for logging in a capybra test in the integration folder.
        log_in_as(@student_1)
        get students_path
        assert_redirected_to login_url
    end
    
    test "Redirect destroy for wrong user" do
        log_in_as @student_1
        assert_no_difference 'Student.count' do
            delete student_path(@student_1) 
        end
    end
    
    test "can edit student in your class" do
        log_in_as @teacher_1
        @teacher_1.update(:current_class => @seminar.id)
        patch student_path(@student_3), params: { student: { first_name:  "Valid",
                                              last_name: "Valid",
                                              email: "e@mail.com",
                                              password:              "valid",
                                              password_confirmation: "valid" } }
        assert_redirected_to scoresheet_seminar_path(@seminar)
        @student_3.reload
        assert_equal "Valid", @student_3.first_name
    end
    
    test "cannot edit student not in your class" do
        old_first_name = @student_3.first_name
        log_in_as @other_teacher
        patch student_path(@student_3), params: { student: { first_name:  "Valid",
                                              last_name: "Valid",
                                              email: "e@mail.com",
                                              password:              "valid",
                                              password_confirmation: "valid" } }
        assert_redirected_to login_path
        @student_3.reload
        assert_equal old_first_name, @student_3.first_name
    end
    
    test "Redirect destroy for teacher" do
        log_in_as @teacher_1
        assert_no_difference 'Student.count', -1 do
            delete student_path(@student_1) 
        end
    end
    
    test "Allow destroy for admin" do
        log_in_as @admin_user
        assert_difference 'Student.count', -1 do
            delete student_path(@student_1) 
        end
    end

end
