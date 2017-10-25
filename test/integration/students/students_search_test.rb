require 'test_helper'

class StudentsSearchTest < ActionDispatch::IntegrationTest

  def setup
    setup_users()
    setup_seminars
    @student_80 = users(:student_80)
    setup_seminars
  end
  
  test 'Test Searching' do
    capybara_login(@teacher_1)
    click_on('1st Period')
    click_on('Add an Existing Student')
    
    assert_no_text(@student_1.last_name_first)
    fill_in "search_field", with: @student_1.user_number
    click_button('Search')
    assert_text(@student_1.last_name_first)
    
    fill_in "search_field", with: @student_2.user_number
    click_button('Search')
    assert_text(@student_2.last_name_first)
    assert_no_text(@student_1.last_name_first)
    
    fill_in "search_field", with: @student_1.last_name
    choose('Last name')
    click_button('Search')
    assert_text(@student_1.last_name_first)
    
    fill_in "search_field", with: 758
    click_button('Search')
    assert_text("Nothing found for that search")
    assert_no_text(@student_1.last_name_first)
    
    fill_in "search_field", with: @student_2.first_name
    choose('First name')
    click_button('Search')
    assert_text(@student_2.last_name_first)
    
    fill_in "search_field", with: @student_1.email
    choose('E-mail')
    click_button('Search')
    assert_text(@student_1.last_name_first)
    
    fill_in "search_field", with: @student_2.id
    choose('Id')
    click_button('Search')
    assert_text(@student_2.last_name_first)
    assert_text("Already registered for this class")
    
    fill_in "search_field", with: @other_school_student.id
    choose('Id')
    click_button('Search')
    assert_no_text(@other_school_student.last_name_first)
    
    assert_not_equal @teacher_1, @student_90.sponsor    # Student sponsored by another teacher
    fill_in "search_field", with: @student_90.id
    choose('Id')
    click_button('Search')
    assert_text(@student_90.last_name_first)
  end
  
  
  test 'add student to class' do
    first_assign = @seminar.objectives.first
    @os = @student_80.objective_students.create(:objective => first_assign, :points => 8)   # for testing the benchmark
    
    capybara_login(@teacher_1)
    click_on('1st Period')
    click_on('Add an Existing Student')
    
    #Setup before adding student
    oldAulaCount = SeminarStudent.count
    #seatChartCount = @seminar.seating.count
    oldScoreCount = ObjectiveStudent.count
    assignmentCount = @seminar.objectives.select{|x| !@student_80.objectives.include?(x) }.count
    assert assignmentCount > 0
    assert_not @seminar.students.include?(@student_80)
    
    # Search for and add the student
    assert_no_text(@student_1.last_name_first)
    fill_in "search_field", with: @student_80.user_number
    click_button('Search')
    assert_text(@student_80.last_name_first)
    click_button('Add to this class')
    
    #After adding student
    @new_aula = SeminarStudent.last
    @new_student = Student.find(@new_aula.user_id)
    assert_equal @new_student, @student_80
    assert_equal 1, @new_aula.pref_request
    assert_equal true, @new_aula.present
    assert_equal 8, @new_aula.benchmark
    assert_equal oldAulaCount + 1, SeminarStudent.count
    assert_equal @teacher_1, @new_student.sponsor
    
    @seminar.reload
    assert @seminar.students.include?(@student_80)
    #assert_equal seatChartCount + 1, @seminar.seating.count
    assert_equal oldScoreCount + assignmentCount, ObjectiveStudent.count
    assert_equal 1, @student_80.objective_students.where(:objective => first_assign).count
  end
  
  test "unverified teacher" do
    capybara_login(@unverified_teacher)
    click_on('unverified teachers class')
    click_on('Add an Existing Student')
    
    fill_in "search_field", with: @student_1.user_number
    click_button('Search')
    assert_no_text(@student_1.last_name_first)
  end
  
end