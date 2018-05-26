require 'test_helper'

class CheckpointTest < ActiveSupport::TestCase
  
  def setup
    setup_users
    setup_goals
  
    @gs_1 = @student_2.goal_students.first
    @checkpoint_1 = @gs_1.checkpoints.first
    @checkpoint_1.update(:action => "I will be on time for (?) of the days this term.")
  end
  
  test "grade percentage lower" do
    @checkpoint_1.update(:achievement => 40)
    @gs_1.update(:target => 50)
    
    assert_equal 70, @checkpoint_1.grade_percentage
  end
  
  test "grade percentage equal" do
    @checkpoint_1.update(:achievement => 50)
    @gs_1.update(:target => 50)
    
    assert_equal 100, @checkpoint_1.grade_percentage
  end
  
  test "grade percentage over" do
    @checkpoint_1.update(:achievement => 60)
    @gs_1.update(:target => 50)
    
    assert_equal 100, @checkpoint_1.grade_percentage
  end
  
  test "grade percentage cant go below zero" do
    @checkpoint_1.update(:achievement => 5)
    @gs_1.update(:target => 100)
    
    assert_equal 10, @checkpoint_1.grade_percentage
  end
  
  test "but it can equal zero" do
    @checkpoint_1.update(:achievement => 0)
    @gs_1.update(:target => 100)
    
    assert_equal 0, @checkpoint_1.grade_percentage
  end
  
  test "rounding" do
    @checkpoint_1.update(:achievement => 40)
    @gs_1.update(:target => 45)
    
    assert_equal 78, @checkpoint_1.grade_percentage
  end
  
  test "missing achievement" do
    @checkpoint_1.update(:achievement => nil)
    @gs_1.update(:target => 50)
    
    assert_equal "", @checkpoint_1.grade_percentage
  end
  
  test "missing target" do
    @checkpoint_1.update(:achievement => 40)
    @gs_1.update(:target => nil)
    
    assert_equal "", @checkpoint_1.grade_percentage
  end
  
  test "use straight percentage for non targeted action" do
    @checkpoint_1.update(:action => "I will choose an on-time buddy")
    @checkpoint_1.update(:achievement => 75)
    @gs_1.update(:target => 90)
    
    assert_equal 75, @checkpoint_1.grade_percentage
  end
end
