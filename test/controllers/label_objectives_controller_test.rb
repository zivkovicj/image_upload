
=begin

require 'test_helper'

class LabelObjectivesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @label_objective = label_objectives(:one)
  end

  test "should get index" do
    get label_objectives_url
    assert_response :success
  end

  test "should get new" do
    get new_label_objective_url
    assert_response :success
  end

  test "should create label_objective" do
    assert_difference('LabelObjective.count') do
      post label_objectives_url, params: { label_objective: {  } }
    end

    assert_redirected_to label_objective_url(LabelObjective.last)
  end

  test "should show label_objective" do
    get label_objective_url(@label_objective)
    assert_response :success
  end

  test "should get edit" do
    get edit_label_objective_url(@label_objective)
    assert_response :success
  end

  test "should update label_objective" do
    patch label_objective_url(@label_objective), params: { label_objective: {  } }
    assert_redirected_to label_objective_url(@label_objective)
  end

  test "should destroy label_objective" do
    assert_difference('LabelObjective.count', -1) do
      delete label_objective_url(@label_objective)
    end

    assert_redirected_to label_objectives_url
  end
end

=end