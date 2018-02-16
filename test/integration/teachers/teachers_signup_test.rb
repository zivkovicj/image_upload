require 'test_helper'

class TeachersSignupTest < ActionDispatch::IntegrationTest
    
    def setup
        @old_teacher_count = Teacher.count
        @old_school_count = School.count
        setup_users
    end
    
    def goto_signup_page
        visit('/')
        click_on("Sign up for a new teacher account")
    end
    
    test "new teacher old school" do
        @school = @teacher_1.school
        
        goto_signup_page
        teacher_editing_stuff(nil, 'Create My Account')
        
        assert_equal @old_teacher_count + 1, Teacher.count
        assert_in_delta @this_teacher.created_at, @this_teacher.last_login, 1.minute
        
        assert_nil @this_teacher.school
        fill_in "search_field", with: @school.name
        choose("school_#{@school.id}")
        click_on("This is my school")
        
        @this_teacher.reload
        assert_equal @school, @this_teacher.school
        assert_equal 0, @this_teacher.verified
        
        click_on("Create a New Class")
        fill_in "seminar[name]", with: "Myname"
        click_on("Create This Class")
        
        click_on('Create New Students')
        
        fill_in ("first_name_1"), :with => "Alice"
        fill_in ("last_name_1"), :with => "In Chains"
        fill_in ("first_name_2"), :with => "Pearl"
        fill_in ("last_name_2"), :with => "Jam"
        fill_in ("first_name_3"), :with => "Nir"
        fill_in ("last_name_3"), :with => "Vana"
        fill_in ("first_name_4"), :with => "Sound"
        fill_in ("last_name_4"), :with => "Garden"
        click_on("Create these student accounts")
        
        click_on("Log out")
        
        @new_student = Student.last
        assert_equal "Sound", @new_student.first_name
        assert_equal @this_teacher, @new_student.sponsor
        assert_nil @new_student.school
        
        capybara_login(@teacher_1)
        click_on("goto_verify")
        choose("teacher_#{@this_teacher.id}_approve")
        click_on("Submit these approvals")
        
        @new_student.reload
        assert_equal @school, @new_student.school
    end
    
    test "new teacher new school" do
        goto_signup_page
        teacher_editing_stuff(nil, 'Create My Account')
        
        assert_nil @this_teacher.school
        fill_in "school_name", with: "Slunk Elementary"
        fill_in "school_city", with: "Bucketheadland"
        select('Utah', :from => 'school_state')
        click_on("This is my school")
        
        @this_teacher.reload
        @new_school = School.find_by(:name => "Slunk Elementary")
        assert_equal "Bucketheadland", @new_school.city
        assert_equal "UT", @new_school.state
        assert_equal @new_school, @this_teacher.school
        assert_equal @old_school_count + 1, School.count
        assert_equal @this_teacher, @new_school.mentor
        assert_equal 1, @this_teacher.verified
    end
    
    test "invalid signup information" do
        goto_signup_page
        
        fill_in "teacher_first_name", with: "Burgle"
        click_on('Create My Account')
        
        assert_equal @old_teacher_count, Teacher.count
    end
    
    test "invalid school info" do
        goto_signup_page
        teacher_editing_stuff(nil, 'Create My Account')
        
        assert_text ("Choose Your School")
        assert_no_text("Please complete all information for your school")
        
        fill_in "school_name", with: "Slunk Elementary"
        click_on("This is my school")
        
        @this_teacher.reload
        assert_nil School.find_by(:name => "Slunk Elementary")
        assert_equal @old_school_count, School.count
        assert_equal 0, @this_teacher.verified
        
        assert_text ("Choose Your School")
        assert_text("Please complete all information for your school")
    end
    
    test "no new or old school" do
        goto_signup_page
        teacher_editing_stuff(nil, 'Create My Account')
        
        assert_text ("Choose Your School")
        assert_no_text("Please choose a school or create a new school.")
        
        click_on("This is my school")
        
        @this_teacher.reload
        assert_nil School.find_by(:name => "Slunk Elementary")
        assert_equal @old_school_count, School.count
        assert_equal 0, @this_teacher.verified
        
        assert_text ("Choose Your School")
        assert_text("Please choose a school or create a new school.")
        assert_no_text("Please complete all information for your school")
    end
    
end