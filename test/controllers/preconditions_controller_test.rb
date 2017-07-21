require 'test_helper'

class PreconditionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @precondition = preconditions(:one)
  end

  test "should get index" do
    get preconditions_url
    assert_response :success
  end

  test "should get new" do
    get new_precondition_url
    assert_response :success
  end

  test "should create precondition" do
    assert_difference('Precondition.count') do
      post preconditions_url, params: { precondition: {  } }
    end

    assert_redirected_to precondition_url(Precondition.last)
  end

  test "should show precondition" do
    get precondition_url(@precondition)
    assert_response :success
  end

  test "should get edit" do
    get edit_precondition_url(@precondition)
    assert_response :success
  end

  test "should update precondition" do
    patch precondition_url(@precondition), params: { precondition: {  } }
    assert_redirected_to precondition_url(@precondition)
  end

  test "should destroy precondition" do
    assert_difference('Precondition.count', -1) do
      delete precondition_url(@precondition)
    end

    assert_redirected_to preconditions_url
  end
end
