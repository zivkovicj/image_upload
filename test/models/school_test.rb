require 'test_helper'

class SchoolTest < ActiveSupport::TestCase
  
  def setup
    setup_users
    setup_schools
  end
  
  test "unverified_teachers" do
    @last_teacher = Teacher.last
    @unverified_teachers = @school.unverified_teachers
    assert @unverified_teachers.include?(@last_teacher)
    assert_not @unverified_teachers.include?(@teacher_1)
  end
  
  test "school commodities needing delivered" do
    com_stud_1 = CommodityStudent.find_or_create_by(:user => @school.students.first, :commodity => @school.commodities.deliverable.first)
    com_stud_2 = CommodityStudent.find_or_create_by(:user => @school.students.second, :commodity => @school.commodities.deliverable.first)
    com_stud_3 = CommodityStudent.find_or_create_by(:user => @school_2.students.first, :commodity => @school_2.commodities.first)
    com_stud_4 = CommodityStudent.find_or_create_by(:user => @school.students.first, :commodity => @school.commodities.non_deliverable.first)
    
    com_stud_1.update(:quantity => 3, :delivered => false)
    com_stud_2.update(:quantity => 3, :delivered => true)
    com_stud_3.update(:quantity => 3, :delivered => false)
    com_stud_4.update(:quantity => 3, :delivered => false)
    
    these_coms = @school.commodities_needing_delivered
    assert these_coms.include?(com_stud_1)
    assert_not these_coms.include?(com_stud_2)
    assert_not these_coms.include?(com_stud_3)
    assert_not these_coms.include?(com_stud_4)
  end
end
