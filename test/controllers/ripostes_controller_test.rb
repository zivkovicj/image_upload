require 'test_helper'

class RipostesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @riposte = ripostes(:one)
  end

  test "should get index" do
    get ripostes_url
    assert_response :success
  end

  test "should get new" do
    get new_riposte_url
    assert_response :success
  end

  test "should create riposte" do
    assert_difference('Riposte.count') do
      post ripostes_url, params: { riposte: {  } }
    end

    assert_redirected_to riposte_url(Riposte.last)
  end

  test "should show riposte" do
    get riposte_url(@riposte)
    assert_response :success
  end

  test "should get edit" do
    get edit_riposte_url(@riposte)
    assert_response :success
  end

  test "should update riposte" do
    patch riposte_url(@riposte), params: { riposte: {  } }
    assert_redirected_to riposte_url(@riposte)
  end

  test "should destroy riposte" do
    assert_difference('Riposte.count', -1) do
      delete riposte_url(@riposte)
    end

    assert_redirected_to ripostes_url
  end
end
