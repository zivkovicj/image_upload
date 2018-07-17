require 'test_helper'

class SchoolsControllerTest < ActionDispatch::IntegrationTest
   
    def setup
        setup_users
        setup_schools
        @school_url = "/schools/#{@school.id}/edit?"
    end
    
    test "url to teacher edit" do
        capybara_login(@teacher_1)
    
        visit(@school_url)
        
        assert_selector('h2', :text => "Edit #{@school.name}")
    end
    
    test "wrong teacher url to teacher edit" do
        @other_teacher = @school.teachers.third
        assert_equal 0, @other_teacher.school_admin
        
        capybara_login(@other_teacher)
        
        visit(@school_url)
        
        assert_no_selector('h2', :text => "Edit #{@school.name}")
        assert_selector('strong', :text => "Teacher Since:")
    end
    
    test "admin url to teacher edit" do
        capybara_login(@admin_user)
        
        visit(@school_url)
        
        assert_selector('h2', :text => "Edit #{@school.name}")
    end
    
    test "no login url to teacher edit" do
        visit(@school_url)
        assert_no_selector('h2', :text => "Edit #{@school.name}")
        assert_selector('h1', "Log in")
    end
end