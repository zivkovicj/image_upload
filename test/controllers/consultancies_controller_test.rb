
=begin

require 'test_helper'

class ConsultanciesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @consultancy = consultancies(:one)
  end

  test "should get index" do
    get consultancies_url
    assert_response :success
  end

  test "should get new" do
    get new_consultancy_url
    assert_response :success
  end

  test "should create consultancy" do
    assert_difference('Consultancy.count') do
      post consultancies_url, params: { consultancy: {  } }
    end

    assert_redirected_to consultancy_url(Consultancy.last)
  end

  test "should show consultancy" do
    get consultancy_url(@consultancy)
    assert_response :success
  end

  test "should get edit" do
    get edit_consultancy_url(@consultancy)
    assert_response :success
  end

  test "should update consultancy" do
    patch consultancy_url(@consultancy), params: { consultancy: {  } }
    assert_redirected_to consultancy_url(@consultancy)
  end

  test "should destroy consultancy" do
    assert_difference('Consultancy.count', -1) do
      delete consultancy_url(@consultancy)
    end

    assert_redirected_to consultancies_url
  end
end

=end