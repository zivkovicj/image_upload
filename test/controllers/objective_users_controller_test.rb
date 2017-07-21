require 'test_helper'

class ObjectiveUsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @objective_user = objective_users(:one)
  end

  test "should get index" do
    get objective_users_url
    assert_response :success
  end

  test "should get new" do
    get new_objective_user_url
    assert_response :success
  end

  test "should create objective_user" do
    assert_difference('ObjectiveUser.count') do
      post objective_users_url, params: { objective_user: {  } }
    end

    assert_redirected_to objective_user_url(ObjectiveUser.last)
  end

  test "should show objective_user" do
    get objective_user_url(@objective_user)
    assert_response :success
  end

  test "should get edit" do
    get edit_objective_user_url(@objective_user)
    assert_response :success
  end

  test "should update objective_user" do
    patch objective_user_url(@objective_user), params: { objective_user: {  } }
    assert_redirected_to objective_user_url(@objective_user)
  end

  test "should destroy objective_user" do
    assert_difference('ObjectiveUser.count', -1) do
      delete objective_user_url(@objective_user)
    end

    assert_redirected_to objective_users_url
  end
end
