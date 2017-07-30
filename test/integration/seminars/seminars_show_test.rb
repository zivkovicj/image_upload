require 'test_helper'

class SeminarsShowTest < ActionDispatch::IntegrationTest
    
    def setup
        @user = users(:michael)
        @teacher_user = users(:archer)
        @seminar = seminars(:one)
        setup_scores()
    end
    
    test "redirect if incorrect user" do
        
    end
    
    test "show scoresheet" do
        capybara_teacher_login()
        click_on("scoresheet_#{@seminar.id}")
        assert_selector('h1', :text => "#{@seminar.name} Scoresheet")
        assert page.has_title? "#{@seminar.name} Scoresheet | EM Education"
        assert_match @seminar.students.count.to_s, page.body
        @seminar.students.each do |student|
            assert_match student.lastNameFirst, page.body
        end
        bdth = []
        @seminar.objectives.each do |objective|
            bdth.push(objective)
        end
        bdth.each do |objective|
           assert_selector("a", :text  => objective.shortName, count: 1)
        end
    end
    
    test "click into student view" do
        capybara_teacher_login()
        click_on("scoresheet_#{@seminar.id}")
        thisStudent = @seminar.students[2]
        click_on(thisStudent.lastNameFirst)
        assert_selector("h1", :text => thisStudent.lastNameFirst)
        
    end
    
end