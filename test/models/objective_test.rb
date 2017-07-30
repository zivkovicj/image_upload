require 'test_helper'

class ObjectiveTest < ActiveSupport::TestCase
  def setup
    @objective = Objective.new(name: "Slope")
  end
  
  test "should be valid" do
    assert @objective.valid?
  end
  
  test "name should not be nil" do
    @objective.name = nil
    assert_not @objective.valid?
  end
  
  test "name should be present" do
    @objective.name = "  "
    assert_not @objective.valid?
  end
  
  test "length of name" do
    @objective.name = "a"*41
    assert_not @objective.valid?
  end
end
