require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @admin     = users(:michael)
    @non_admin = users(:archer)
  end

  test "user index" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.first_name
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end

  test "user index as non-admin" do
    log_in_as(@non_admin)
    get users_path
    assert_redirected_to login_url
  end
  
  test "back button" do
    capybara_admin_login()
    click_on("Users Index")
    assert_selector("h1", :text => "All Users")
    assert_no_text("Desk-Consultant Facilitator Since:")
    click_on("back_button")
    assert_text("Desk-Consultant Facilitator Since:") 
  end
  
  test "delete user" do
    setup_objectives()
    
    old_user_count = User.count
    old_objective_count = Objective.count
    archers_objectives = Objective.where(:user => @non_admin).count
    assert archers_objectives > 0
    
    capybara_admin_login()
    click_on("Users Index")
    click_on("delete_#{@non_admin.id}")
    
    assert_equal old_user_count - 1, User.count
    assert_equal old_objective_count - archers_objectives, Objective.count
  end
end