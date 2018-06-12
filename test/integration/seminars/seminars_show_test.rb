require 'test_helper'

class SeminarsShowTest < ActionDispatch::IntegrationTest
    
    def setup
        setup_users
        setup_schools
        setup_seminars
        setup_scores
    end
    
    test "click into student view" do
        capybara_login(@teacher_1)
        click_on("scoresheet_#{@seminar.id}")
        thisStudent = @seminar.students[2]
        click_on(thisStudent.last_name_first)
        assert_selector("h1", :text => thisStudent.last_name_first)
    end
    
end