require 'test_helper'

class SchoolsTermTest < ActionDispatch::IntegrationTest
    
    def setup
        setup_users
        setup_schools
    end
    
    test "don't change term" do
        travel_to Time.zone.local(2019, 01, 18, 01, 04, 44)
        
        capybara_login(@teacher_1)
        assert_equal 1, @teacher_1.school.reload.term
    end
    
    test "change term" do
        travel_to Time.zone.local(2019, 01, 20, 01, 04, 44)
        
        capybara_login(@teacher_1)
        assert_equal 2, @teacher_1.school.reload.term
    end
    
end