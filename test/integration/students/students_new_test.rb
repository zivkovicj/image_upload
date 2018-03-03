require 'test_helper'

class StudentsNewTest < ActionDispatch::IntegrationTest
    
    def setup
        setup_users
        setup_seminars
        @old_stud_count = Student.count
    end
    
    test 'create new students' do
        assert_not_nil @teacher_1.school
        old_ss_count = SeminarStudent.count
        old_score_count = ObjectiveStudent.count
        old_goal_student_count = @seminar.goal_students.count
        assignmentCount = @seminar.objectives.count
        
        go_to_create_student_view
        
        fill_in ("first_name_1"), :with => "Phil"
        fill_in ("last_name_1"), :with => "Labonte"
        
        fill_in ("first_name_2"), :with => "Other_kid"
        fill_in ("last_name_2"), :with => "Burgaboot"
        fill_in ("user_number_2"), :with => "5"
        
        fill_in ("first_name_3"), :with => "Ed"
        fill_in ("last_name_3"), :with => ""
        
        fill_in ("first_name_5"), :with => "Kid"
        fill_in ("last_name_5"), :with => "with Password"
        fill_in ("password_5"), :with => "Bean Sprouts"
        
        fill_in ("first_name_6"), :with => "Chick"
        fill_in ("last_name_6"), :with => "with Username"
        fill_in ("username_6"), :with => "My_Username"  #Caps that should be downcased
        
        fill_in ("first_name_7"), :with => "Dude"
        fill_in ("last_name_7"), :with => "with Email"
        fill_in ("email_7"), :with => "dude@email.com"
        
        click_on("Create these student accounts")
        
        assert_equal @old_stud_count+5, Student.count
        assert_equal old_score_count + (assignmentCount*5), ObjectiveStudent.count
        assert_equal old_ss_count + 5, SeminarStudent.count
        assert_equal old_goal_student_count + 20, @seminar.goal_students.count
        @gs = @seminar.goal_students.order(:created_at).last
        assert_equal 4, @gs.checkpoints.count
        
        first_new_student = Student.find_by(:last_name => "Labonte")
        thisId = first_new_student.id
        assert_equal thisId, first_new_student.user_number
        assert_equal "pl#{thisId}", first_new_student.username 
        assert first_new_student.authenticate(thisId)
        assert_equal "", first_new_student.email
        assert_equal first_new_student.created_at, first_new_student.last_login
        assert_equal @teacher_1.school, first_new_student.school
        
        second_new_student = Student.find_by(:last_name => "Burgaboot")
        assert @seminar.students.include?(second_new_student)
        assert_equal "Other_kid", second_new_student.first_name
        assert_equal "Burgaboot", second_new_student.last_name
        assert_equal 5, second_new_student.user_number
        assert_equal second_new_student.username, "ob5"
        assert second_new_student.authenticate("5")
        
        third_new_student = Student.find_by(:last_name => "with Password")
        assert third_new_student.authenticate("Bean Sprouts")
        
        fourth_new_student = Student.find_by(:last_name => "with Username")
        assert_equal "my_username", fourth_new_student.username
        
        fifth_new_student = Student.find_by(:last_name => "with Email")
        assert_equal "dude@email.com", fifth_new_student.email
        
        @new_aula = SeminarStudent.find_by(:seminar_id => @seminar.id, :user => first_new_student)
        assert_equal 1, @new_aula.pref_request
        assert_equal true, @new_aula.present
        
        assert_text("#{@seminar.name} Scoresheet")
    end
    
    test "username already taken" do
        @student_1.update!(:username => "nabwaffle49")
        
        go_to_create_student_view
        
        fill_in ("first_name_1"), :with => "Kid"
        fill_in ("last_name_1"), :with => "Stealing Username"
        fill_in ("username_1"), :with => "nabwaffle49"
        click_on("Create these student accounts")
        
        this_student = Student.find_by(:last_name => "Stealing Username")
        id_num = this_student.id
        assert_equal "ks#{id_num}", this_student.username
    end
    
    test "user_number too long" do
        go_to_create_student_view
        
        fill_in ("first_name_1"), :with => "Kid"
        fill_in ("last_name_1"), :with => "with Too-Long Username"
        fill_in ("user_number_1"), :with => 2000000001
        click_on("Create these student accounts")
        
        this_student = Student.find_by(:last_name => "with Too-Long Username")
        id_num = this_student.id
        assert_equal id_num, this_student.id
    end
    
    test "make_username" do
        go_to_create_student_view
        
        fill_in ("first_name_1"), :with => "Abigail"
        fill_in ("last_name_1"), :with => "Barnes"
        fill_in ("user_number_1"), :with => 5
        
        fill_in ("first_name_2"), :with => "Abigail"
        fill_in ("last_name_2"), :with => "Barnes"
        fill_in ("user_number_2"), :with => 5
        
        fill_in ("first_name_3"), :with => "Abigail"
        fill_in ("last_name_3"), :with => "Barnes"
        fill_in ("user_number_3"), :with => 5
        
        fill_in ("first_name_4"), :with => "Abigail"
        fill_in ("last_name_4"), :with => "Barnes"
        fill_in ("user_number_4"), :with => 5
        
        fill_in ("first_name_5"), :with => "Abigail"
        fill_in ("last_name_5"), :with => "Barnes"
        fill_in ("user_number_5"), :with => 5
        
        click_on("Create these student accounts")
        
        assert_equal @old_stud_count + 5, Student.count
        
        stud_1 = Student.all[-5]
        assert_equal "ab5", stud_1.username
        
        stud_2 = Student.all[-4]
        assert_equal "abigailb5", stud_2.username
        
        stud_3 = Student.all[-3]
        assert_equal "abarnes5", stud_3.username
        
        stud_4 = Student.all[-2]
        assert_equal "abigailbarnes5", stud_4.username
        
    end
    
    test "nil school if teacher unverified" do
        assert_not_nil @teacher_1.school
        @teacher_1.update(:verified => 0)
        
        go_to_create_student_view
        
        fill_in ("first_name_1"), :with => "Phil"
        fill_in ("last_name_1"), :with => "Labonte"
        click_on("Create these student accounts")
        
        assert_equal @old_stud_count+1, Student.count
        first_new_student = Student.find_by(:last_name => "Labonte")
        assert_nil first_new_student.school
    end
    
end