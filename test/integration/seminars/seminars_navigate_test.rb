
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
        
        click_on("scoresheet_#{@seminar.id}")
        assert_text("#{@seminar.name} Scoresheet")
        
        click_on("other_class_scoresheet_#{@seminar_2.id}")
        assert_text("#{@seminar_2.name} Scoresheet")
        
        click_on("other_class_scoresheet_#{@seminar.id}")
        assert_text("#{@seminar.name} Scoresheet")
        
        click_on("same_class_desk_consult_#{@seminar.id}")
        assert_text(show_consultancy_headline(@seminar.consultancies.last))
        
        click_on("other_class_desk_consult_#{@seminar_2.id}")
        assert_text(new_consultancy_headline)
        
        click_on("same_class_student_goals_#{@seminar_2.id}")
        assert_text("Student Goals for #{@seminar_2.name}")
        
        click_on("other_class_student_goals_#{@seminar.id}")
        assert_text("Student Goals for #{@seminar.name}")
        
        click_on("same_class_edit_#{@seminar.id}")
        assert_text("Edit #{@seminar.name}")
        
        click_on("other_class_edit_#{@seminar_2.id}")
        assert_text("Edit #{@seminar_2.name}")
    end
end