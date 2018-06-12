require 'test_helper'

class SchoolsControllerTest < ActionDispatch::IntegrationTest
   
    def setup
        setup_users
        setup_schools
        @school_url = "/schools/#{@school.id}/verify?"
    end
    
    test "url to teacher verify" do
        capybara_login(@teacher_1)
    
        visit(@school_url)
        
        assert_selector('h1', :text => "Verify Teachers")
    end
    
    test "wrong teacher url to teacher verify" do
        @other_teacher = @school.teachers.third
        assert_not_equal @other_teacher, @school.mentor
        
        capybara_login(@other_teacher)
        
        visit(@school_url)
        
        assert_no_selector('h1', :text => "Verify Teachers")
        assert_selector('strong', :text => "Teacher Since:")
    end
    
    test "admin url to teacher verify" do
        capybara_login(@admin_user)
        
        visit(@school_url)
        
        assert_selector('h1', :text => "Verify Teachers")
    end
end