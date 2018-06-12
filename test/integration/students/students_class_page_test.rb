require 'test_helper'

class StudentsClassPageTest < ActionDispatch::IntegrationTest
    
    def setup
        setup_users
        setup_schools
        setup_seminars
        setup_goals
        setup_scores
    end
    
    test 'class page navigate' do
        capybara_login(@student_2)
        click_on(@seminar.name)
        
        #The visible tags aren't working right now.
        assert_selector('h3', :text => "2nd Term Goal")
    end
    
end