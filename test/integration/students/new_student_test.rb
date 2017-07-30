require 'test_helper'

class NewStudentTest < ActionDispatch::IntegrationTest
    
    def setup
        @seminar = seminars(:one)
    
    end
    
    test 'Create New Student' do
        oldStudCount = Student.count
        oldAulaCount = SeminarStudent.count
        oldScoreCount = ObjectiveStudent.count
        assignmentCount = @seminar.objectives.count
        
        capybara_teacher_login()
        click_on('1st Period')
        
        click_on('Create New Students')
        fill_in ("first_name_1"), :with => "Phil"
        fill_in ("last_name_1"), :with => "Labonte"
        
        fill_in ("first_name_2"), :with => "Bill"
        fill_in ("last_name_2"), :with => "LaFonte"
        fill_in ("student_number_2"), :with => "5"
        
        fill_in ("first_name_3"), :with => "Ed"
        fill_in ("last_name_3"), :with => ""
        click_on("Create these student accounts")
        
        assert_equal oldStudCount+2, Student.count
        assert_equal oldScoreCount + (assignmentCount*2), ObjectiveStudent.count
        assert_equal oldAulaCount + 2, SeminarStudent.count
        
        @newStudent = Student.last
        assert @seminar.students.include?(@newStudent)
        assert_equal @newStudent.first_name, "bill"
        assert_equal @newStudent.last_name, "lafonte"
        assert_equal @newStudent.student_number, 5
        assert_equal @newStudent.username, "bl5"
        assert @newStudent.authenticate("5")
        
        @otherNew = Student.find_by(:last_name => "labonte")
        thisId = @otherNew.id
        assert_equal @otherNew.student_number, thisId
        assert_equal @otherNew.username, "pl#{thisId}"
        assert @otherNew.authenticate(thisId)
        
        @new_aula = SeminarStudent.find_by(:seminar_id => @seminar.id, :student_id => @newStudent.id)
        assert_equal 1, @new_aula.pref_request
        
        assert_text("#{@seminar.name} Scoresheet")
        
    end
    
end