require 'test_helper'

class SeminarsIndexTest < ActionDispatch::IntegrationTest

  def setup
    @admin     = users(:michael)
    @non_admin = users(:archer)
    @seminar = seminars(:one)
  end

  test "seminar index" do
    log_in_as(@admin)
    get seminars_path
    assert_template 'seminars/index'
    assert_select 'div.pagination'
    first_page_of_seminars = Seminar.paginate(page: 1)
    first_page_of_seminars.each do |seminar|
      assert_select 'a[href=?]', seminar_path(seminar), text: seminar.name
    end
    assert_difference 'Seminar.count', -1 do
      delete seminar_path(@seminar)
    end
  end

  test "Seminar index as non-admin" do
    log_in_as(@non_admin)
    get seminars_path
    assert_redirected_to login_url
  end
  
  test "seminars back button" do
      capybara_admin_login()
      click_on("Seminars")
      assert_selector("h1", :text => "All Classes")
      assert_no_text("Desk-Consultant Facilitator Since:")
      click_on("back_button")
      assert_text("Desk-Consultant Facilitator Since:") 
  end
end