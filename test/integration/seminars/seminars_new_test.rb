require 'test_helper'

class SeminarsNewTest < ActionDispatch::IntegrationTest
   
   test "Create New Seminar" do
       capybara_teacher_login()
       click_on("Create a New Class")
       
       fill_in "Name", with: "4th Period"
       choose('80')
       click_on("Create a New Class")
       assert_text "4th Period Scoresheet"
       
       @new_seminar = Seminar.last
       assert @new_seminar.name == "4th Period"
       assert @new_seminar.consultantThreshold == 80
   end 
   
   test "Default Threshold" do
       capybara_teacher_login()
       click_on("Create a New Class")
       
       fill_in "Name", with: "5th Period"
       @new_seminar = Seminar.last
       assert_equal 70, @new_seminar.consultantThreshold
   end
    
end