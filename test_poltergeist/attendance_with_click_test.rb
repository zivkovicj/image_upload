
require 'test_helper'

class AttendanceWithClickTest < ActionDispatch::IntegrationTest
   
    def setup
        setup_users
        setup_seminars
    end
   
   test "attendance with click" do
        poltergeist_stuff
        @ss = @seminar.seminar_students.first
        assert @ss.present
        @ss_2 = @seminar.seminar_students.second
        @ss_2.update(:present => false)
        @student = @ss.user
        @student_2 = @ss_2.user
        
        capybara_login(@teacher_1)
        click_on("desk_consult_#{@seminar.id}")
        
        within(:css, "#attendance_div_#{@ss.id}") do
            assert_text(@student.first_plus_init)
            assert_text("Present")
            assert_no_text("Absent")
        end
        within(:css, "#attendance_div_#{@ss_2.id}") do
            assert_text(@student_2.first_plus_init)
            assert_text("Absent")
            assert_no_text("Present")
        end
        
        find("#attendance_div_#{@ss.id}").click
        find("#attendance_div_#{@ss_2.id}").click
        
        within(:css, "#attendance_div_#{@ss.id}") do
            assert_text(@student.first_plus_init)
            assert_no_text("Present")
            assert_text("Absent")
        end
        within(:css, "#attendance_div_#{@ss_2.id}") do
            assert_text(@student_2.first_plus_init)
            assert_no_text("Absent")
            assert_text("Present")
        end
        
        assert_not @ss.reload.present
        assert @ss_2.reload.present
    end
    
end