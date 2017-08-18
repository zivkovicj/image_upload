require 'test_helper'

class StudentsControllerTest < ActionDispatch::IntegrationTest
    
    def setup
        setup_users()
        setup_seminars()
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

    # The test for adding a NEW student to the class and seating chart is here.
    # The test for adding an existing student to the class and seating chart is in
    # the aulas controller.
    

    test "Auto user_number" do
        post students_path, params: { students: [{ first_name: "Noob",
                                    last_name: "Sauce" }],
                                    ss: { seminar_id: @seminar.id } }
        student = assigns(:student)
        assert_equal student.id, student.user_number
    end
    
    test "Auto makeUsername" do
        post students_path, params: { students: [{ first_name:  "Archibald",
                                             last_name: "Bachelorpad",
                                             user_number: 5}],
                                     ss: { seminar_id: @seminar.id } }
        student = assigns(:student)
        assert_equal "ab5", student.username
        
        post students_path, params: { students: [{ first_name:  "Abigail",
                                             last_name: "Barnes",
                                             user_number: 5}],
                                     ss: { seminar_id: @seminar.id } }
        student = assigns(:student)
        assert_equal "abigailb5", student.username
        
        post students_path, params: { students: [{ first_name:  "Abigail",
                                             last_name: "Barnes",
                                             user_number: 5}],
                                     ss: { seminar_id: @seminar.id } }
        student = assigns(:student)
        assert_equal "abarnes5", student.username
        
        post students_path, params: { students: [{ first_name:  "Abigail",
                                             last_name: "Barnes",
                                             user_number: 5}],
                                     ss: { seminar_id: @seminar.id } }
        student = assigns(:student)
        assert_equal "abigailbarnes5", student.username
        
        post students_path, params: { students: [{ first_name:  "Abigail",
                                             last_name: "Barnes",
                                             user_number: 5}],
                                     ss: { seminar_id: @seminar.id } }
        student = assigns(:student)
        assert_nil student.username
    end
    
    test "auto password" do
        post students_path, params: { students: [{ first_name:  "Ren",
                                             last_name: "Stimpy",
                                            user_number: 13}],
                                     ss: { seminar_id: @seminar.id } }
        student = assigns(:student)
        assert_equal "rs13", student.username
        assert student.authenticate("13")
    end
    
    test "Keep unique username upon new student or updating" do
        @student_1.update!(:username => "nq72")
        assert_equal "nq72", @student_1.username
        
        oldusername = @student_3.username
        @student_3.update(:username => "nq72")
        @student_3.reload
        assert_equal oldusername, @student_3.username
    end

end
