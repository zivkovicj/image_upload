require 'test_helper'

class TeachersSignupTest < ActionDispatch::IntegrationTest
    
    def setup
        @old_teacher_count = Teacher.count 
    end
    
    test "signup new teacher" do
        visit('/')
        click_on("Sign up for a new teacher account")
        teacher_editing_stuff(nil, 'Create My Account')
        
        assert_equal @old_teacher_count + 1, Teacher.count
    end
    
    test "invalid signup information" do
        visit('/')
        click_on("Sign up for a new teacher account")
        
        fill_in "teacher_first_name", with: "Burgle"
        click_on('Create My Account')
        
        assert_equal @old_teacher_count, Teacher.count
    end
    
    
end