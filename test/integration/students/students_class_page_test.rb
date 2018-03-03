require 'test_helper'

class StudentsClassPageTest < ActionDispatch::IntegrationTest
    
    def setup
        setup_users
        setup_seminars
        setup_goals
        setup_scores
    end
    
    test 'class page navigate' do
        capybara_login(@student_2)
        click_on(@seminar.name)
        
        #The visible tags aren't working right now.
        assert_selector('h3', :text => "Your Goal for 2nd Term", :visible => true)
        assert_selector('h2', :text => "Quizzes Available", :visible => true)
        assert_selector("h3", :text => "Consultant Request", :visible => false)
        assert_selector("h3", :text => "Total Stars Earned:", :visible => false)
    end
    
end