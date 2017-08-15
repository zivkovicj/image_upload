require 'test_helper'

class ConsultanciesIndexTest < ActionDispatch::IntegrationTest
    
    include ConsultanciesHelper
    
    def setup
        setup_seminars
    end
    
    test "teacher has none yet" do
        capybara_login(@seminar.user)
        click_on("index_consult_#{@seminar.id}")
        
        assert_text(no_consultancies_message)
    end
    
    test "teacher has one and link to it" do
        setup_consultancies
        
        capybara_login(@seminar.user)
        click_on("index_consult_#{@seminar.id}")
        
        assert_no_text(no_consultancies_message)
        click_on("consultancy_#{Consultancy.last.id}")
        
        assert_text(show_consultancy_headline)
    end
    
    test "link to new consultancy" do
        capybara_login(@seminar.user)
        click_on("index_consult_#{@seminar.id}")
        
        click_on("desk_consult_#{@seminar.id}")
        assert_text(new_consultancy_headline)
    end
    
end