require 'test_helper'

class SeminarsShowTest < ActionDispatch::IntegrationTest
    
    def setup
        setup_users()
        setup_seminars
        setup_scores()
    end
    
    test "redirect if incorrect user" do
        
    end
    
    test "show scoresheet" do
        capybara_login(@teacher_1)
        click_on("scoresheet_#{@seminar.id}")
        assert_selector('h1', :text => "#{@seminar.name} Scoresheet")
        assert page.has_title? "#{@seminar.name} Scoresheet | EM Education"
        assert_match @seminar.students.count.to_s, page.body
        @seminar.students.each do |student|
            assert_match student.last_name_first, page.body
        end
        bdth = []
        @seminar.objectives.each do |objective|
            bdth.push(objective)
        end
        bdth.each do |objective|
           assert_selector("a", :text  => objective.short_name, count: 1)
        end
    end
    
    test "click into student view" do
        capybara_login(@teacher_1)
        click_on("scoresheet_#{@seminar.id}")
        thisStudent = @seminar.students[2]
        click_on(thisStudent.last_name_first)
        assert_selector("h1", :text => thisStudent.last_name_first)
        
    end
    
end