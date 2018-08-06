require 'test_helper'

class StudentTest < ActiveSupport::TestCase
  def setup
    @student = Student.new(first_name: "Beef", last_name: "Stroganoff", 
          email: "user@example.com", 
          password: "foobar", password_confirmation: "foobar")
  end
  
  test "quiz stars this term" do
    setup_users
    setup_objectives
    setup_seminars
    setup_scores
    
    score_count = @seminar.objectives.count
    @student_2.objective_students.update_all(:current_scores => [1,2,3,10])
    @student_2.objective_students.last.update(:current_scores => [nil,nil,nil,nil])
    
    #assert_equal score_count - 1, @student_2.stars_this_term(@seminar, 0)
    assert_equal ((score_count - 1) * 2), @student_2.quiz_stars_this_term(@seminar, 1)
  end
  
  test "should be valid" do
    assert @student.valid?
  end
  
  test "first name should be present" do
    @student.first_name = "    "
    assert_not @student.valid?
  end
  
  test "last name should be present" do
    @student.last_name = "    "
    assert_not @student.valid?
  end
  
  test "first name should not be too long" do
    @student.first_name = "a" * 26
    assert_not @student.valid?
  end
  
  test "last name should not be too long" do
    @student.last_name = "a" * 26
    assert_not @student.valid?
  end

  test "email should not be too long" do
    @student.email = "a" * 244 + "@example.com"
    assert_not @student.valid?
  end
  
  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @student.email = valid_address
      assert @student.valid?, "#{valid_address.inspect} should be valid"
    end
  end
    
  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @student.email = invalid_address
      assert_not @student.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email addresses should be unique" do
    duplicate_user = @student.dup
    duplicate_user.email = @student.email.upcase
    @student.save
    assert_not duplicate_user.valid?
  end
  
  test "uniqueness against a teacher" do
    @teacher = Teacher.first
    @student.email = @teacher.email
    assert_not @student.valid?
  end
  
  test "authenticated? should return false for a user with nil digest" do
    assert_not @student.authenticated?(:remember, '')
  end
  
  test "advance to next school year" do
    setup_users
    setup_seminars
    setup_scores
    
    @this_obj_stud = @student_2.objective_students.first
    @student_2.update(:school_year => 2)
    @this_obj_stud.update(:current_scores => [4,5,6,7])
    
    @student_2.advance_to_next_school_year
    
    @student_2.reload
    @this_obj_stud.reload
    should_array = [[nil, nil, nil, nil], [nil, nil, nil, nil], [4, 5, 6, 7], [nil, nil, nil, nil], [nil, nil, nil, nil], [nil, nil, nil, nil], [nil, nil, nil, nil], [nil, nil, nil, nil], [nil, nil, nil, nil], [nil, nil, nil, nil], [nil, nil, nil, nil], [nil, nil, nil, nil], [nil, nil, nil, nil], [nil, nil, nil, nil], [nil, nil, nil, nil], [nil, nil, nil, nil], [nil, nil, nil, nil], [nil, nil, nil, nil], [nil, nil, nil, nil], [nil, nil, nil, nil]]
    assert_equal should_array, @this_obj_stud.score_record
    assert_equal [nil,nil,nil,nil], @this_obj_stud.current_scores
    assert_equal 3, @student_2.school_year
  end
  
  test "assets" do
    setup_users
    setup_seminars
    setup_schools
    
    @student_2.currencies.create(:seminar => @seminar, :giver => @teacher, :value => 10)
    @student_2.currencies.create(:seminar => @seminar, :giver => @teacher, :value => 11)
    @student_2.currencies.create(:seminar => nil, :school => @school, :giver => @teacher, :value => 12)
    @student_2.currencies.create(:seminar => nil, :school => @school, :giver => @teacher, :value => 13)
    assert_equal 21, @student_2.bucks_earned(:seminar, @seminar)
    assert_equal 25, @student_2.bucks_earned(:school, @school)
    
    @student_2.commodity_students.create(:seminar => @seminar, :commodity => Commodity.first, :price_paid => 1, :delivered => true)
    @student_2.commodity_students.create(:seminar => @seminar, :commodity => Commodity.first, :price_paid => 2, :delivered => true)
    @student_2.commodity_students.create(:seminar => @seminar, :commodity => Commodity.first, :price_paid => 3, :delivered => false)
    @student_2.commodity_students.create(:seminar => @seminar, :commodity => Commodity.second, :price_paid => 4, :delivered => false)
    @student_2.commodity_students.create(:seminar => @seminar, :commodity => Commodity.second, :price_paid => 5, :delivered => false)
    @student_2.commodity_students.create(:school => @school, :commodity => @school.commodities.first, :price_paid => 3, :delivered => true)
    @student_2.commodity_students.create(:school => @school, :commodity => @school.commodities.first, :price_paid => 4, :delivered => false)
    
    assert_equal 15, @student_2.bucks_spent(:seminar, @seminar)
    assert_equal 7, @student_2.bucks_spent(:school, @school)
    
    assert_equal 6, @student_2.bucks_current(:seminar, @seminar)
    assert_equal 18, @student_2.bucks_current(:school, @school)
    assert_equal 3, @student_2.com_quant(Commodity.first)
    assert_equal 2, @student_2.com_quant_delivered(Commodity.first)
  end
  
  test "points" do
    setup_users
    setup_objectives
    setup_seminars
    setup_schools
    
    term_1_start_date = Date.strptime(@school.term_dates[1][0], "%m/%d/%Y")
    term_2_start_date = Date.strptime(@school.term_dates[2][0], "%m/%d/%Y")
    
    @student_2.quizzes.create(:total_score => 9, :updated_at => term_1_start_date - 5.days, :objective => @objective_10, :origin => "pretest")
    @student_2.quizzes.create(:total_score => 8, :updated_at => term_1_start_date - 5.days, :objective => @objective_10, :origin => "teacher_granted")
    @student_2.quizzes.create(:total_score => 3, :updated_at => term_2_start_date - 6.days, :objective => @objective_10, :origin => "teacher_granted")
    @student_2.quizzes.create(:total_score => 10, :updated_at => term_2_start_date - 6.days, :objective => @objective_20, :origin => "teacher_granted")
    @student_2.quizzes.create(:total_score => 4, :updated_at => term_2_start_date - 5.days, :objective => @objective_10, :origin => "teacher_granted")
    @student_2.quizzes.create(:total_score => 5, :updated_at => term_2_start_date + 5.days, :objective => @objective_10, :origin => "teacher_granted")
    
    
    assert_equal 4, @student_2.points_this_term(@objective_10, 1)
    assert_equal 5, @student_2.points_this_term(@objective_10, 2)
    assert_equal 8, @student_2.points_all_time(@objective_10)
  end

end
