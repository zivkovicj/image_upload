require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
    @other_user = users(:archer)
    @seminar = seminars(:one)
  end
  
  test "Teacher signup form" do
    get signup_path
    assert_template 'users/new'
    assert_select 'form' do
      assert_select 'input'
    end
  end
  
  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: { user: { first_name:  "",
                                         last_name:  "",
                                         email: "user@invalid",
                                         password:              "foo",
                                         password_confirmation: "bar"} }
    end
    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'div.field_with_errors'
  end
  
  test "valid signup information and activation" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { title: "Mr.",
                                          first_name:  "Example",
                                         last_name: "User",
                                         email: "user@example.com",
                                         password:              "password",
                                         password_confirmation: "password" } }
    end
    #assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    #assert_not user.activated?
    
    # Invalid activation token
    #get edit_account_activation_path("invalid token", email: user.email)
    #assert_not user.activated?
    
    # Valid token, wrong email
    #get edit_account_activation_path(user.activation_token, email: 'wrong')
    #assert_not user.activated?
    
    # Valid token and email
    #get edit_account_activation_path(user.activation_token, email: user.email)
    #assert user.reload.activated?
    
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
    assert_not flash.empty?
    assert_equal "teacher", user.role 
  end

  
end