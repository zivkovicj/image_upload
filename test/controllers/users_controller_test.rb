require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

  # Tests for removing a student from a class period are in the SeminarStudents controller test.
  
  def setup
    @user = users(:michael)
    @teacher_user = users(:archer)
    @student = students(:student_1)
    @seminar = seminars(:one)
  end
  
  test "should redirect index when not logged in" do
    get users_path
    assert_redirected_to login_url
  end
  
  test "users index as admin" do
    log_in_as(@user)
    get users_path
    assert_template 'users/index'
  end
  
  test "users index as non-admin" do
    log_in_as(@teacher_user)
    get users_path
    assert_redirected_to login_url
  end

  test "should get new" do
    get signup_path
    assert_response :success
  end

  test "should redirect show if not logged in" do
    get user_path(@user)
    assert_redirected_to login_path
  end

  test "should redirect edit when not logged in" do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    patch user_path(@user), params: { user: { first_name: @user.first_name,
                                              email: @user.email } }
    assert_not flash.empty?
    assert_redirected_to login_url
  end
  
  test "should redirect destroy when not logged in" do
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy when logged in as a non-admin" do
    log_in_as(@teacher_user)
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to login_url
  end

end
