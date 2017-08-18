require 'test_helper'

class SeminarsNewTest < ActionDispatch::IntegrationTest
   
    def setup
        setup_users()
    end
   
    test "create new seminar" do
        setup_objectives
        obj_array = [@objective_30, @objective_40, @objective_50, @own_assign]
        capybara_login(@teacher_1)
        click_on("Create a New Class")
       
        fill_in "Name", with: "4th Period"
        choose('80')
        obj_array.each do |obj|
            check("check_#{obj.id}")
        end
        click_on("Create This Class")
       
        @seminar = Seminar.last
        assert @seminar.name == "4th Period"
        assert @seminar.consultantThreshold == 80
        obj_array.each do |obj|
            assert @seminar.objectives.include?(obj)
        end
        establish_objectives(@seminar)
        4.times do |n|
            this_obj = instance_variable_get("@os_#{n}")
            assert_equal 0, this_obj.pretest
        end
        check("pretest_on_#{@obj_0.id}")
        check("pretest_on_#{@obj_3.id}")
        click_on("Update Pretests")
        
        reload_oss
        assert_equal 1, @os_0.pretest
        assert_equal 0, @os_1.pretest
        assert_equal 0, @os_2.pretest
        assert_equal 1, @os_3.pretest
        assert_equal 2, @os_2.priority
        assert_equal 2, @os_3.priority
        choose("#{@os_2.id}_3")
        choose("#{@os_3.id}_0")
        click_on("Update these priorities")
        
        reload_oss
        assert_equal 3, @os_2.priority
        assert_equal 0, @os_3.priority
        assert_on_scoresheet
    end 
   
    test "default threshold" do
       old_seminar_count = Seminar.count
       
       capybara_login(@teacher_1)
       click_on("Create a New Class")
       
       fill_in "Name", with: "5th Period"
       click_on("Create This Class")
       
       assert_equal old_seminar_count + 1, Seminar.count
       @seminar = Seminar.last
       assert_equal 70, @seminar.consultantThreshold
    end
   
    test "class without objectives" do
       capybara_login(@teacher_1)
       click_on("Create a New Class")
       
       fill_in "Name", with: "5th Period"
       click_on("Create This Class")
       
       @seminar = Seminar.last
       assert_on_scoresheet
       assert_no_text("Edit #{@seminar.name} Pre-Tests")
    end
    
end