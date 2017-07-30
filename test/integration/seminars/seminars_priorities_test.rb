require 'test_helper'

class SeminarsPrioritiesTest < ActionDispatch::IntegrationTest
    
    def setup
        @seminar = seminars(:one)
        
        @os_2 = @seminar.objective_seminars[2]
        @os_3 = @seminar.objective_seminars[3]
 
        
    end
    
    test "change objective priorities" do
        capybara_teacher_login()
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