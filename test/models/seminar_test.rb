require 'test_helper'

class SeminarTest < ActiveSupport::TestCase

  def setup
    @user = users(:michael)
    # This code is not idiomatically correct.
    @seminar = @user.own_seminars.build(name: "1st Period", consultantThreshold: 70)
  end

  test "should be valid" do
    assert @seminar.valid?
  end

  test "Teacher id should be present" do
    @seminar.teacher_id = nil
    assert_not @seminar.valid?
  end
  
  test "name should be present" do
    @seminar.name = "   "
    assert_not @seminar.valid?
  end

  test "name should be less than 40 characters" do
    @seminar.name = "a" * 41
    assert_not @seminar.valid?
  end
end