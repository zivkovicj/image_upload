
require 'test_helper'

class SeminarsNavigateTest < ActionDispatch::IntegrationTest

    def setup
        setup_users
        setup_seminars 
        
    end
    
    test "seminar navbar" do
        capybara_login(@teacher_1)
        click_on("scoresheet_#{@seminar.id}")
        
        assert_text("#{@seminar.name} Scoresheet")
    end
end