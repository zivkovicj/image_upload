require 'test_helper'

class SeminarUsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @seminar_user = seminar_users(:one)
  end

  test "should get index" do
    get seminar_users_url
    assert_response :success
  end

  test "should get new" do
    get new_seminar_user_url
    assert_response :success
  end

  test "should create seminar_user" do
    assert_difference('SeminarUser.count') do
      post seminar_users_url, params: { seminar_user: {  } }
    end

    assert_redirected_to seminar_user_url(SeminarUser.last)
  end

  test "should show seminar_user" do
    get seminar_user_url(@seminar_user)
    assert_response :success
  end

  test "should get edit" do
    get edit_seminar_user_url(@seminar_user)
    assert_response :success
  end

  test "should update seminar_user" do
    patch seminar_user_url(@seminar_user), params: { seminar_user: {  } }
    assert_redirected_to seminar_user_url(@seminar_user)
  end

  test "should destroy seminar_user" do
    assert_difference('SeminarUser.count', -1) do
      delete seminar_user_url(@seminar_user)
    end

    assert_redirected_to seminar_users_url
  end
end
