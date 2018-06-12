require 'test_helper'

class SeminarTest < ActiveSupport::TestCase

  def setup
    setup_users
    # This code is not idiomatically correct.
    @test_seminar = @teacher_1.seminars.build(name: "1st Period", consultantThreshold: 7)
  end

  test "should be valid" do
    assert @test_seminar.valid?
  end
  
  test "name should be present" do
    @test_seminar.name = "   "
    assert_not @test_seminar.valid?
  end

  test "name should be less than 40 characters" do
    @test_seminar.name = "a" * 41
    assert_not @test_seminar.valid?
  end
  
  
  
end