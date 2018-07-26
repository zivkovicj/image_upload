require 'test_helper'

class SchoolsTermTest < ActionDispatch::IntegrationTest
    
    def setup
        setup_users
        setup_schools
    end 

    test "create new stars" do
        setup_commodities
        travel_to Time.zone.local(2018, 06, 20, 01, 04, 44)
        capybara_login(@teacher_1)
        
        @teacher_1_star.reload
        # Should add 66
        
        assert_equal 466, @teacher_1_star.quantity
        assert_equal Date.today, @teacher_1_star.date_last_produced
    end
    
    test "create if its been too long" do
        travel_to Time.zone.local(2018, 06, 25, 01, 04, 44)
        assert_equal 1, Date.today.wday
        capybara_login(@teacher_1)
        
        @teacher_1_star.reload
        # Should add 81
        assert_equal 466, @teacher_1_star.quantity
        assert_equal Date.today, @teacher_1_star.date_last_produced
    end
    
    test "dont create too early" do
        travel_to Time.zone.local(2018, 06, 17, 01, 04, 44)
        assert_equal 0, Date.today.wday
        capybara_login(@teacher_1)
        
        @teacher_1_star.reload
        # Should add 81
        assert_equal 400, @teacher_1_star.quantity
        assert_equal @testing_date_last_produced.to_date, @teacher_1_star.date_last_produced
    end
end