
=begin
require 'test_helper'

class ObjectiveSeminarsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @objective_seminar = objective_seminars(:one)
  end

  test "should get index" do
    get objective_seminars_url
    assert_response :success
  end

  test "should get new" do
    get new_objective_seminar_url
    assert_response :success
  end

  test "should create objective_seminar" do
    assert_difference('ObjectiveSeminar.count') do
      post objective_seminars_url, params: { objective_seminar: {  } }
    end

    assert_redirected_to objective_seminar_url(ObjectiveSeminar.last)
  end

  test "should show objective_seminar" do
    get objective_seminar_url(@objective_seminar)
    assert_response :success
  end

  test "should get edit" do
    get edit_objective_seminar_url(@objective_seminar)
    assert_response :success
  end

  test "should update objective_seminar" do
    patch objective_seminar_url(@objective_seminar), params: { objective_seminar: {  } }
    assert_redirected_to objective_seminar_url(@objective_seminar)
  end

  test "should destroy objective_seminar" do
    assert_difference('ObjectiveSeminar.count', -1) do
      delete objective_seminar_url(@objective_seminar)
    end

    assert_redirected_to objective_seminars_url
  end
end

=end