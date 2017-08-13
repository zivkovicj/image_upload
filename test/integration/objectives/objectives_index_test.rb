require 'test_helper'

class ObjectivesIndexTest < ActionDispatch::IntegrationTest

  def setup
    setup_users()
    setup_objectives()
  end

  test "index objectives as admin" do
    capybara_login(@admin_user)
    click_on("All Objectives")

    assert_selector('a', :id => "edit_#{@objective_20.id}", :text => @objective_20.fullName)
    assert_selector('a', :id => "delete_#{@objective_20.id}", :text => "Delete")
    assert_selector('a', :id => "edit_#{@own_assign.id}", :text => @own_assign.fullName)
    assert_selector('a', :id => "delete_#{@own_assign.id}", :text => "Delete")
    assert_selector('a', :id => "edit_#{@other_teacher_objective.id}", :text => @other_teacher_objective.fullName)
    assert_selector('a', :id => "delete_#{@other_teacher_objective.id}", :text => "Delete")
  end

  test "index objectives as non admin" do
    capybara_login(@teacher_1)
    click_on("All Objectives")
    
    assert_selector('a', :id => "edit_#{@objective_20.id}", :text => @objective_20.fullName)
    assert_selector('a', :id => "delete_#{@objective_20.id}", :text => "Delete", :count => 0)
    assert_selector('a', :id => "edit_#{@own_assign.id}", :text => @own_assign.fullName)
    assert_selector('a', :id => "delete_#{@own_assign.id}", :text => "Delete")
    assert_selector('a', :id => "edit_#{@other_teacher_objective.id}", :text => @other_teacher_objective.fullName, :count => 0)
    assert_selector('a', :id => "delete_#{@other_teacher_objective.id}", :text => "Delete",:count => 0)
  end
  
  test "back button" do
    capybara_login(@teacher_1)
    click_on("All Objectives")
    assert_not_on_teacher_page
    click_on("back_button")
    assert_on_teacher_page
  end
end