
=begin
require 'test_helper'

class LabelsControllerTest < ActionDispatch::IntegrationTest
  
  def setup
    @admin_user = users(:michael)
    @teacher_user = users(:archer)
    setup_labels()
  end
  
  test "should get new" do
    log_in_as(@teacher_user)
    get new_label_url
    assert_response :success
  end
  
  test "redirect new labels when not logged in" do
    get new_label_url
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "get edit labels" do
    log_in_as(@teacher_user)
    get edit_label_url(@admin_l)
    assert_template 'labels/edit'
  end

  test "redirect edit labels when not logged in" do
    get edit_label_path(@admin_l)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should get index" do
    log_in_as(@teacher_user)
    get labels_index_url
    assert_response :success
  end
  
  test "redirect index when not logged in" do
    get labels_index_url
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "admin can destroy" do
    log_in_as(@admin_user)
    delete label_path(@admin_l)
    assert_response :success
    delete label_path(@user_l)
    assert_response :success
    delete label_path(@other_l_pub)
    assert_response :success
  end

  test "user can destroy own" do
    log_in_as(@teacher_user)
    
    delete label_path(@user_l)
    assert_response :success
  end
  
  test "user cannot destroy others" do
    log_in_as(@teacher_user)
    delete label_path(@other_l_pub)
    assert_not flash.empty?
    assert_redirected_to login_url
  end
  
  test "user cannot destroy admin" do
    log_in_as(@teacher_user)
    delete label_path(@admin_l)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

end

=end