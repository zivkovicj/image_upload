require 'test_helper'

class ConsultanciesIndexTest < ActionDispatch::IntegrationTest
    
    include ConsultanciesHelper
    
    def setup
        setup_users
        setup_schools
        setup_seminars
    end
    
    test "link to one" do
        setup_consultancies
        
        capybara_login(@teacher_1)
        click_on("consultancy_#{@seminar.id}")
        click_on("List All Arrangements")
        
        click_on("consultancy_#{@consultancy_from_setup.id}")
        
        assert_text(show_consultancy_headline(@consultancy_from_setup))
    end
    
    test "link to new consultancy" do
        setup_consultancies
        
        capybara_login(@teacher_1)
        click_on("consultancy_#{@seminar.id}")
        click_on("List All Arrangements")
        
        click_on("new_consultancy")
        assert_text(new_consultancy_headline)
    end
    
    test "delete consultancy" do
        setup_consultancies
        old_consultancy_count = Consultancy.count
        
        capybara_login(@teacher_1)
        click_on("consultancy_#{@seminar.id}")
        click_on("List All Arrangements")
        
        find("#delete_#{@consultancy_from_setup.id}").click
        click_on("confirm_#{@consultancy_from_setup.id}")
        
        assert_no_text(no_consultancies_message)
        
        find("#delete_#{@other_consultancy.id}").click
        click_on("confirm_#{@other_consultancy.id}")
        
        assert_text(no_consultancies_message)
        
        assert_equal old_consultancy_count - 2, Consultancy.count
    end
    
end