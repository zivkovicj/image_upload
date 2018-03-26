require 'test_helper'

class GoalsCheckpointPrintTest < ActionDispatch::IntegrationTest
    
    def setup
        setup_users
        setup_seminars
        setup_goals
    end
    
    test "visit printing page" do
        @seminar.update(:term => 3, :which_checkpoint => 2)
        
        capybara_login(@teacher_1)
        go_to_goals
        click_on("Printable Version")
        
        assert_text("Printable Goals for Term 4, Checkpoint 3")
        @seminar.students.each do |student|
            assert_text("#{student.first_name} #{student.last_name}")
        end
        
        click_on("Back to Viewing Goals")
        assert_text("Showing Goals for Term 4, Checkpoint 3")
    end
end