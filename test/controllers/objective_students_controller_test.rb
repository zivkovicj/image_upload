require 'test_helper'

class ObjectiveStudentsControllerTest < ActionDispatch::IntegrationTest
  
  def setup
    @teacher_user = users(:archer)
    setup_scores_and_commodities()
  end
  
  test "integer points" do
    log_in_as @teacher_user
    @score = ObjectiveStudent.last
    assert @score.valid?
    @score.update(:points => 8.5)
    assert_not @score.valid?
    assert_equal ["must be an integer"], @score.errors.messages[:points]
  end
  
  test "positive points" do
    log_in_as @teacher_user
    @score = ObjectiveStudent.last
    assert @score.valid?
    @score.update(:points => -8)
    assert_not @score.valid?
    assert_equal ["must be greater than or equal to 0"], @score.errors.messages[:points]
  end

end
