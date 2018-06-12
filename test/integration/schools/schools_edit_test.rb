require 'test_helper'

class SchoolsEditTest < ActionDispatch::IntegrationTest
    
    def setup
        setup_users
        setup_schools
    end
    
    test "edit_term_dates" do
        capybara_login(@teacher_1)
        assert_selector('input', :id => "edit_school_#{@school.id}")
        find("#edit_school_#{@school.id}").click
        fill_in "school[term_dates][2][1]", with: "06/06/2019"
        click_on("Save Changes")
        
        @school.reload
        new_date_array = [["08/14/2018","10/27/2018"],
         ["10/28/2018","01/19/2019"],
         ["01/20/2019","06/06/2019"],
         ["03/24/2019","06/05/2019"]]
        assert_equal new_date_array, @school.term_dates
    end
    
    test "other teacher cannot edit school" do
        capybara_login(@other_teacher)
        assert_no_selector('input', :id => "edit_school_#{@school.id}" )
    end
    
end