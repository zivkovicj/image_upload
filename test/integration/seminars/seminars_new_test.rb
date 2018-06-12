require 'test_helper'

class SeminarsNewTest < ActionDispatch::IntegrationTest
   
    def setup
        setup_users
        setup_schools
        @old_seminar_count = Seminar.count
        setup_objectives
    end
    
    test "create new seminar" do
        capybara_login(@teacher_1)
        click_on("Create a New Class")
       
        fill_in "seminar[name]", with: "4th Period"
        click_on("Create This Class")
       
        assert_equal @old_seminar_count + 1, Seminar.count
        @seminar = Seminar.last
        assert_equal "4th Period",  @seminar.name
        assert_equal 7, @seminar.consultantThreshold
        
        assert_selector('h2', "Edit #{@seminar.name}")
    end
    
    test "seminar back link" do
        capybara_login(@teacher_1)
        click_on("Create a New Class")
        
        click_on("back_button")
        
        assert_text("Mr. Z School Teacher Since:")
        assert_equal @old_seminar_count, Seminar.count
    end
   
    test "empty seminar name" do
        capybara_login(@teacher_1)
        click_on("Create a New Class")
        click_on("Create This Class")
        
        assert_equal @old_seminar_count, Seminar.count
        assert_selector('h1', :text => "New Class")
        assert_selector('div', :id => "error_explanation")
        assert_selector('li', :text => "Name can't be blank")
    end
end