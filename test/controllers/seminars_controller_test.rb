require 'test_helper'

class SeminarsControllerTest < ActionDispatch::IntegrationTest
  
  include SetObjectivesAndScores
  
  def setup
    @user = users(:michael)
    @teacher_user = users(:archer)
    @zacky = users(:zacky)
    @seminar = seminars(:one)
    setup_scores()
  end
  
  test "seminars index test" do
    log_in_as(@user)
    get seminars_path
    assert_template 'seminars/index'
  end
  
  test "seminars index as non-admin" do
    log_in_as(@teacher_user)
    get seminars_path
    assert_redirected_to login_url
  end
  
  test "should redirect destroy when not logged in" do
    assert_no_difference 'Seminar.count' do
      delete seminar_path(@seminar)
    end
    assert_redirected_to login_url
  end
  
  test "should redirect destroy when logged in as wrong user" do
    log_in_as @zacky
    assert_no_difference 'Seminar.count' do
      delete seminar_path(@seminar)
    end
    assert_redirected_to login_url
  end
  
  test "should delete when logged in" do
  # Also checks that objectives and seminar_students are automatically deleted.
    log_in_as @teacher_user
    oldAssignCount = ObjectiveSeminar.count
    thisClassAssigns = @seminar.objectives.count
    assert_operator thisClassAssigns, :>, 0
    old_ss_count = SeminarStudent.count
    this_class_ss = @seminar.seminar_students.count
    assert_operator this_class_ss, :>, 0
    assert_difference 'Seminar.count', -1 do
      delete seminar_path(@seminar)
    end
    assert_equal oldAssignCount - thisClassAssigns, ObjectiveSeminar.count
    assert_equal old_ss_count - this_class_ss, SeminarStudent.count
    assert_redirected_to @teacher_user
  end
  
  test "delete seminar_students upon deleting class" do
    log_in_as @teacher_user
    num_ss = -1 * @seminar.seminar_students.count
    assert_difference 'SeminarStudent.count', num_ss do
      delete seminar_path(@seminar)  
    end
  end
  
  test "should redirect create when not logged in" do
    assert_no_difference 'Seminar.count' do
      post '/seminars/', params: { seminar: { name: "2nd period",  consultantThreshold: 70 } }
    end
  end
  
  test "empty class name" do
    log_in_as @teacher_user
    assert_no_difference 'Seminar.count' do
      post '/seminars/', params: { seminar: { name: " ",  consultantThreshold: 70 } }
    end
    assert_template 'seminars/new'
  end
  
  test "class name too long" do
    log_in_as @teacher_user
    assert_no_difference 'Seminar.count' do
      post '/seminars/', params: { seminar: { name: "a"*41,  consultantThreshold: 70 } }
    end
    assert_template 'seminars/new'
  end
  
  test "set_objectives_and_scores" do
    whut = set_objectives_and_scores(true)
    @objective_2 = objectives(:objective_20)
    @objective_7 = objectives(:objective_70)
    assert whut[0].include?(@objective_2)
    assert_not whut[0].include?(@assigment_7)
    assert whut[1].include?(@objective_2.id)
    assert_not whut[1].include?(@objective_7.id)
    assert whut[2].include?(@objective_2.objective_students.first)
    assert_not whut[2].include?(@objective_7.objective_students.first)
  end
  
  
end
