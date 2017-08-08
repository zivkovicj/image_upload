require 'test_helper'

class TeachersShowTest < ActionDispatch::IntegrationTest
    
    def setup
        setup_users()
    end
    
    test "show" do
        log_in_as @teacher_1
        get teacher_path(@teacher_1)
        assert_template 'teachers/show'
        assert_select 'title', full_title(@teacher_1.name_with_title)
        #assert_select 'h1>img.gravatar'
        assert_match @teacher_1.own_seminars.count.to_s, response.body
        @teacher_1.own_seminars.each do |seminar|
            assert_match seminar.name, response.body
        end
    end
    
end