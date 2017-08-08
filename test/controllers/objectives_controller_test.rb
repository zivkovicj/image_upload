require 'test_helper'

class ObjectivesControllerTest < ActionDispatch::IntegrationTest
  
  def setup
    setup_users()
    setup_seminars
    @objective = objectives(:objective_20)
    @objective40 = objectives(:objective_40)
    setup_objectives()
    setup_scores()

  end

  test "objectives index test" do
    log_in_as(@teacher_1)
    get objectives_path
    assert_template 'objectives/index'
  end
  
  test "objectives index as non-admin" do
    log_in_as(@teacher_1)
    get objectives_path
    # Should test that admin gets delete links for publics
    # Non-admin doesn't get those links.
  end
  
  test "edit as non-admin" do
    oldName = @objective.name
    
    log_in_as(@teacher_1)
    patch objective_path(@objective), params: { objective: { name:  "Burgersauce",
                                          seminar_id: @seminar.id } }
                                          
    @objective.reload
    assert_equal oldName, @objective.name
  end
  
  test "edit without login" do
    oldName = @objective.name
    
    log_in_as(@teacher_1)
    patch objective_path(@objective), params: { objective: { name:  "Burgersauce",
                                          seminar_id: @seminar.id } }
                                          
    @objective.reload
    assert_equal oldName, @objective.name
  end

  test "delete an objective" do
    # also check whether it deletes scores
    # and resets student requests

    oldobjectiveCount = Objective.count
    oldId = @objective40.id
    oldScoreCount = ObjectiveStudent.count
    old_os_count = ObjectiveSeminar.count
    studentCount = @seminar.students.count
    assert Precondition.where(:mainassign_id => oldId).count > 0
    assert Precondition.where(:preassign_id => oldId).count > 0

    @ss = @seminar.seminar_students.first
    @ss.update(:teach_request => oldId)
    @second_ss = @seminar.seminar_students.second
    @second_ss.update(:learn_request => oldId)
    assert_equal @ss.teach_request, oldId
    assert_equal @second_ss.learn_request, oldId
    
    capybara_login(@teacher_1)
    click_on("All Objectives")
    click_on("delete_#{@objective40.id}")
    
    assert Precondition.where(:mainassign_id => oldId).count == 0
    assert Precondition.where(:preassign_id => oldId).count == 0
    assert_equal oldobjectiveCount - 1, Objective.count
    assert_equal oldScoreCount - studentCount, ObjectiveStudent.count
    assert_equal old_os_count - 1, ObjectiveSeminar.count
    
    @ss.reload
    @second_ss.reload
    assert_not_equal oldId, @ss.teach_request
    assert_not_equal oldId, @second_ss.learn_request
  end
  
  test "wrong user can't delete" do
    log_in_as @other_teacher
    assert_no_difference 'Objective.count' do
      delete objective_path(@objective40)
    end
  end

  test "successful objective edit" do
    log_in_as(@teacher_1)
    assignToEdit = Objective.where(:user_id => @teacher_1.id).first
    
    get seminar_path(@seminar)
    get edit_objective_path(assignToEdit)
    #assert_select "a", :href => seminar_path(@seminar), text: "Back to #{@seminar.name}"
    name  = "Pretzels"
    patch objective_path(assignToEdit), params: { objective: { name:  name,
                                              seminar_id: @seminar.id } }
    assert_not flash.empty?
    assert_redirected_to quantities_objective_path(assignToEdit)
    assignToEdit.reload
    assert_equal name.downcase,  assignToEdit.name
  end
  

end
