require 'test_helper'

class ObjectivesIndexTest < ActionDispatch::IntegrationTest

  def setup
    setup_users()
    @publicobjective = objectives(:objective_30)
    @thisTeachersobjective = objectives(:objective_40)
    @otherTeachersobjective = objectives(:objective_160)
    setup_objectives()
  end

  test "index objectives as admin" do
    capybara_login(@admin_user)
    click_on("All Objectives")

    assert_selector('a', :id => "edit_#{@publicobjective.id}", :text => @publicobjective.fullName)
    assert_selector('a', :id => "delete_#{@publicobjective.id}", :text => "Delete")
    assert_selector('a', :id => "edit_#{@thisTeachersobjective.id}", :text => @thisTeachersobjective.fullName)
    assert_selector('a', :id => "delete_#{@thisTeachersobjective.id}", :text => "Delete")
    assert_selector('a', :id => "edit_#{@otherTeachersobjective.id}", :text => @otherTeachersobjective.fullName)
    assert_selector('a', :id => "delete_#{@otherTeachersobjective.id}", :text => "Delete")
  end

  test "index objectives as non admin" do
    capybara_login(@teacher_1)
    click_on("All Objectives")
    
    assert_selector('a', :id => "edit_#{@publicobjective.id}", :text => @publicobjective.fullName)
    assert_selector('a', :id => "delete_#{@publicobjective.id}", :text => "Delete", :count => 0)
    assert_selector('a', :id => "edit_#{@thisTeachersobjective.id}", :text => @thisTeachersobjective.fullName)
    assert_selector('a', :id => "delete_#{@thisTeachersobjective.id}", :text => "Delete")
    assert_selector('a', :id => "edit_#{@otherTeachersobjective.id}", :text => @otherTeachersobjective.fullName, :count => 0)
    assert_selector('a', :id => "delete_#{@otherTeachersobjective.id}", :text => "Delete",:count => 0)
  end
  
  test "back button" do
    capybara_login(@teacher_1)
    click_on("All Objectives")
    assert_not_on_teacher_page
    click_on("back_button")
    assert_on_teacher_page
  end
end