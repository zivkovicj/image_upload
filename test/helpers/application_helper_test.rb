require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test "full title helper" do
    assert_equal full_title,         "Mr. Z School"
    assert_equal full_title("Help"), "Help | EM Education"
  end
end