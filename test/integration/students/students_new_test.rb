require 'test_helper'

class StudentsNewTest < ActionDispatch::IntegrationTest
    
    def setup
        setup_users
        setup_seminars
        @old_stud_count = Student.count
    end
    
    test 'Create New Student' do
        setup_users
        
        oldAulaCount = SeminarStudent.count
        oldScoreCount = ObjectiveStudent.count
        assignmentCount = @seminar.objectives.count
        
        capybara_login(@teacher_1)
        click_on("scoresheet_#{@seminar.id}")
        click_on('Create New Students')
        
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
        assert_equal oldScoreCount + (assignmentCount*5), ObjectiveStudent.count
        assert_equal oldAulaCount + 5, SeminarStudent.count
        
        first_new_student = Student.find_by(:last_name => "Labonte")
        thisId = first_new_student.id
        assert_equal thisId, first_new_student.user_number
        assert_equal "pl#{thisId}", first_new_student.username 
        assert first_new_student.authenticate(thisId)
        assert_equal "", first_new_student.email
        
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
        
        assert_text("#{@seminar.name} Scoresheet")
    end
    
    test "username already taken" do
        @student_1.update!(:username => "nabwaffle49")
        capybara_login(@teacher_1)
        click_on("scoresheet_#{@seminar.id}")
        click_on('Create New Students')
        
        fill_in ("first_name_1"), :with => "Kid"
        fill_in ("last_name_1"), :with => "Stealing Username"
        fill_in ("username_1"), :with => "nabwaffle49"
        click_on("Create these student accounts")
        
        this_student = Student.find_by(:last_name => "Stealing Username")
        id_num = this_student.id
        assert_equal "ks#{id_num}", this_student.username
    end
    
end