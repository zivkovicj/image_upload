require 'test_helper'

class SeminarsPretestAndPrioritiesTest < ActionDispatch::IntegrationTest
    
    def setup
        setup_users
        setup_seminars
        
        @os_2 = @seminar.objective_seminars[2]
        @os_3 = @seminar.objective_seminars[3]
        
    end
    
    test "change pretests" do
        establish_objectives(@seminar)
        
        @os_0.update(:pretest => 0)
        @os_1.update(:pretest => 0)
        @os_2.update(:pretest => 1)
        @os_3.update(:pretest => 1)
        
        capybara_login(@teacher_1)
        click_on("edit_seminar_#{@seminar.id}")
        click_on("Update Class")
        
        check("pretest_on_#{@obj_0.id}")
        uncheck("pretest_on_#{@obj_3.id}")
        click_on("Update Pretests")
        reload_oss
        
        assert_equal 1, @os_0.pretest
        assert_equal 0, @os_1.pretest
        assert_equal 1, @os_2.pretest
        assert_equal 0, @os_3.pretest
    end
    
    test "change objective priorities" do
        capybara_login(@teacher_1)
        click_on("#{@seminar.name} priorities")
        
        choose("#{@os_2.id}_3")
        choose("#{@os_3.id}_0")
        click_on("Update these priorities")
        
        @os_2.reload
        @os_3.reload
        assert_equal 3, @os_2.priority
        assert_equal 0, @os_3.priority
    
    end
    
end