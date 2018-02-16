require 'test_helper'

class SeminarsEditTest < ActionDispatch::IntegrationTest
   
    def setup
        setup_users
        setup_seminars
    end
    
    def due_date_array
        [["06/05/2019","06/05/2019","06/05/2019","06/05/2019"],
         ["06/05/2019","06/05/2019","06/05/2019","06/05/2019"],
         ["06/05/2019","06/05/2019","06/05/2019","06/05/2019"],
         ["06/05/2019","06/05/2019","06/05/2019","06/05/2019"]]
    end
   
    test "edit seminar" do
        setup_objectives
        obj_array = [@objective_30, @objective_40, @objective_50, @own_assign]
        @os_0 = @seminar.objective_seminars.find_by(:objective => @objective_30)
        @os_1 = @seminar.objective_seminars.find_by(:objective => @objective_40)
        @os_2 = @seminar.objective_seminars.find_by(:objective => @objective_50)
        @os_3 = @seminar.objective_seminars.find_by(:objective => @own_assign)
        @os_2.update(:pretest => 1)
        @os_3.update(:pretest => 1)
        assert_equal 2, @os_2.priority
        assert_equal 2, @os_3.priority
        
        capybara_login(@teacher_1)
        click_on("edit_seminar_#{@seminar.id}")
        
        obj_array.each do |obj|
            check("check_#{obj.id}")
        end
        click_on("Update This Class")
        
        obj_array.each do |obj|
            assert @seminar.objectives.include?(obj)
        end
       
        fill_in "Name", with: "Macho Taco Period"
        choose('8')
        check("pretest_on_#{@objective_30.id}")
        uncheck("pretest_on_#{@objective_50.id}")
        choose("#{@os_2.id}_3")
        choose("#{@os_3.id}_0")
        4.times do |n|
            4.times do |m|
                fill_in "seminar[checkpoint_due_dates][#{n}][#{m}]", with: due_date_array[n][m]
            end
        end
        
        click_on("Update This Class")
        
        @seminar.reload
        assert_equal "Macho Taco Period",  @seminar.name
        assert 8, @seminar.consultantThreshold

        @os_0.reload
        @os_1.reload
        @os_2.reload
        @os_3.reload
    
        assert_equal due_date_array, @seminar.checkpoint_due_dates
        
        assert_equal 1, @os_0.pretest
        assert_equal 0, @os_1.pretest
        assert_equal 0, @os_2.pretest
        assert_equal 1, @os_3.pretest

        assert_equal 3, @os_2.priority
        assert_equal 0, @os_3.priority
        
        assert_selector('h2', "Edit #{@seminar.name}")
    end
end