require 'test_helper'

class StudentsControllerTest < ActionDispatch::IntegrationTest
    
    def setup
        @admin_user = users(:michael)
        @teacher_user = users(:archer)
        @seminar = seminars(:one)
        @student = students(:student_1)
        @other_student = students(:student_2)
    end
    
    test "students index test as admin" do
        # The test for logging in a capybra test in the integration folder.
        log_in_as(@admin_user)
        get students_path
        assert_template 'students/index'
    end
    
    test "students index test as student" do
        # The test for logging in a capybra test in the integration folder.
        log_in_as(@student)
        get students_path
        assert_redirected_to login_url
    end
    
    test "Redirect destroy for wrong user" do
        log_in_as @student
        assert_no_difference 'Student.count' do
            delete student_path(@student) 
        end
    end
    
    test "Allow destroy for teacher" do
        log_in_as @teacher_user
        assert_difference 'Student.count', -1 do
            delete student_path(@student) 
        end
    end
    
    test "Allow destroy for admin" do
        log_in_as @admin_user
        assert_difference 'Student.count', -1 do
            delete student_path(@student) 
        end
    end

    # The test for adding a NEW student to the class and seating chart is here.
    # The test for adding an existing student to the class and seating chart is in
    # the aulas controller.
    

    test "Auto student_number" do
        post students_path, params: { students: [{ first_name: "Noob",
                                    last_name: "Sauce" }],
                                    ss: { seminar_id: @seminar.id } }
        student = assigns(:student)
        assert_equal student.id, student.student_number
    end
    
    test "Auto makeUsername" do
        post students_path, params: { students: [{ first_name:  "Archibald",
                                             last_name: "Bachelorpad",
                                             student_number: 5}],
                                     ss: { seminar_id: @seminar.id } }
        student = assigns(:student)
        assert_equal "ab5", student.username
        
        post students_path, params: { students: [{ first_name:  "Abigail",
                                             last_name: "Barnes",
                                             student_number: 5}],
                                     ss: { seminar_id: @seminar.id } }
        student = assigns(:student)
        assert_equal "abigailb5", student.username
        
        post students_path, params: { students: [{ first_name:  "Abigail",
                                             last_name: "Barnes",
                                             student_number: 5}],
                                     ss: { seminar_id: @seminar.id } }
        student = assigns(:student)
        assert_equal "abarnes5", student.username
        
        post students_path, params: { students: [{ first_name:  "Abigail",
                                             last_name: "Barnes",
                                             student_number: 5}],
                                     ss: { seminar_id: @seminar.id } }
        student = assigns(:student)
        assert_equal "abigailbarnes5", student.username
        
        post students_path, params: { students: [{ first_name:  "Abigail",
                                             last_name: "Barnes",
                                             student_number: 5}],
                                     ss: { seminar_id: @seminar.id } }
        student = assigns(:student)
        assert_equal nil, student.username
    end
    
    test "auto password" do
        post students_path, params: { students: [{ first_name:  "Ren",
                                             last_name: "Stimpy",
                                            student_number: 13}],
                                     ss: { seminar_id: @seminar.id } }
        student = assigns(:student)
        assert_equal "rs13", student.username
        assert student.authenticate("13")
    end
    
    test "Keep unique username upon new student or updating" do
        @student.update!(:username => "nq72")
        assert_equal "nq72", @student.username
        
        oldusername = @other_student.username
        @other_student.update(:username => "nq72")
        @other_student.reload
        assert_equal oldusername, @other_student.username
    end
    
    test "Username already taken upon new student" do
        @student.update!(:username => "nabwaffle49")
        
        assert_no_difference 'Student.count' do
            post students_path, params: { students: [{ first_name:  "Beavis",
                                         last_name: "Butthead",
                                        student_number: 17,
                                        username: "nabwaffle49" }],
                                 ss: { seminar_id: @seminar.id } }
        end
    end
end
