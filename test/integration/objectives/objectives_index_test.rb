require 'test_helper'

class ObjectivesIndexTest < ActionDispatch::IntegrationTest

  def setup
    setup_users
    setup_schools
    setup_objectives
  end

  test "index objectives as admin" do
    capybara_login(@admin_user)
    click_on("All Objectives")

    assert_selector('a', :id => "edit_#{@objective_20.id}", :text => @objective_20.full_name)
    assert_selector('h5', :id => "delete_#{@objective_20.id}", :text => "Delete")
    assert_selector('a', :id => "edit_#{@own_assign.id}", :text => @own_assign.full_name)
    assert_selector('h5', :id => "delete_#{@own_assign.id}", :text => "Delete")
    assert_selector('a', :id => "edit_#{@other_teacher_objective.id}", :text => @other_teacher_objective.full_name)
    assert_selector('h5', :id => "delete_#{@other_teacher_objective.id}", :text => "Delete")
  end

  test "index objectives as non admin" do
    capybara_login(@teacher_1)
    click_on("All Objectives")
    
    assert_selector('a', :id => "edit_#{@objective_20.id}", :text => @objective_20.full_name)
    assert_selector('h5', :id => "delete_#{@objective_20.id}", :text => "Delete", :count => 0)
    assert_selector('a', :id => "edit_#{@own_assign.id}", :text => @own_assign.full_name)
    assert_selector('h5', :id => "delete_#{@own_assign.id}", :text => "Delete")
    assert_selector('a', :id => "edit_#{@other_teacher_objective.id}", :text => @other_teacher_objective.full_name, :count => 0)
    assert_selector('h5', :id => "delete_#{@other_teacher_objective.id}", :text => "Delete",:count => 0)
  end
  
  test "back button" do
    capybara_login(@teacher_1)
    click_on("All Objectives")
    assert_not_on_teacher_page
    click_on("back_button")
    assert_on_teacher_page
  end
  
  test "delete objective" do
    first_private_objective = Objective.find_by(:extent => "private")
    Quiz.create(:objective => first_private_objective, :user => Student.first)
    old_quiz_count = Quiz.count
    
    old_obj_count = Objective.count
    first_lab = @objective_40.labels.first
    assert_not_nil first_lab
    first_sem = @objective_40.seminars.first
    sem_obj_count = first_sem.objectives.count
    preassign = @objective_40.preassigns.first
    preassign_maincount = preassign.mainassigns.count
    mainassign = @objective_40.mainassigns.first
    mainassign_precount = mainassign.preassigns.count
    setup_scores_and_commodities
    oldScoreCount = ObjectiveStudent.count
    old_os_count = ObjectiveSeminar.count
    setup_seminars
    studentCount = @seminar.students.count
    
    @ss = @seminar.seminar_students.first
    obj_id = @objective_40.id
    @ss.update(:teach_request => obj_id)
    @second_ss = @seminar.seminar_students.second
    @second_ss.update(:learn_request => obj_id)
    assert_equal @ss.teach_request, obj_id
    assert_equal @second_ss.learn_request, obj_id
    
    capybara_login(@admin_user)
    click_on("All Objectives")
    
    find("#delete_#{@objective_40.id}").click
    click_on("confirm_#{@objective_40.id}")
    
    first_lab.reload
    first_sem.reload
    preassign.reload
    mainassign.reload
    assert_equal old_obj_count - 1, Objective.count
    assert_equal sem_obj_count - 1, first_sem.objectives.count
    assert_equal preassign_maincount - 1, preassign.mainassigns.count
    assert_equal mainassign_precount - 1, mainassign.preassigns.count
    assert_equal oldScoreCount - studentCount, ObjectiveStudent.count
    assert_equal old_os_count - 1, ObjectiveSeminar.count
  
    @ss.reload
    @second_ss.reload
    assert_not_equal obj_id, @ss.teach_request
    assert_not_equal obj_id, @second_ss.learn_request
    
    find("#delete_#{first_private_objective.id}").click
    click_on("confirm_#{first_private_objective.id}")
    assert_equal old_obj_count - 2, Objective.count
    assert_equal old_quiz_count - 1 , Quiz.count
  end
end