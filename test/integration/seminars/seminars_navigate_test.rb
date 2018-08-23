
require 'test_helper'

class SeminarsNavigateTest < ActionDispatch::IntegrationTest

    include ConsultanciesHelper

    def setup
        setup_users
        setup_schools
        setup_scores
        setup_seminars 
        setup_goals
        setup_consultancies
    end
    
    test "seminar navbar" do
        capybara_login(@teacher_1)
        
        click_on("scoresheet_seminar_#{@seminar.id}")
        assert_text("#{@seminar.name} Scoresheet")
        
        click_on("other_class_#{@seminar_2.id}")
        assert_text("#{@seminar_2.name} Scoresheet")
        
        click_on("other_class_#{@seminar.id}")
        assert_text("#{@seminar.name} Scoresheet")
        
        click_on("consultancy_#{@seminar.id}")
        assert_text(show_consultancy_headline(@seminar.consultancies.last))
        
        click_on("other_class_#{@seminar_2.id}")
        assert_text(new_consultancy_headline)
        
        click_on("goal_students_#{@seminar_2.id}")
        assert_text("Student Goals for #{@seminar_2.name}")
        
        click_on("other_class_#{@seminar.id}")
        assert_text("Student Goals for #{@seminar.name}")
        
        click_on("edit_seminar_#{@seminar.id}")
        assert_text("Edit #{@seminar.name}")
        
        click_on("other_class_#{@seminar_2.id}")
        assert_text("Edit #{@seminar_2.name}")
    end
end