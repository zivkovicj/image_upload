require 'test_helper'

class CommodityStudentTest < ActiveSupport::TestCase
  test "needs delivered" do
    @com_stud = CommodityStudent.find_or_create_by(:user => Student.first, :commodity => Commodity.deliverable.first)
    
    @com_stud.update(:quantity => 3, :delivered => false)
    assert CommodityStudent.needs_delivered.include?(@com_stud)
    
    @com_stud.update(:delivered => true)
    assert_not CommodityStudent.needs_delivered.include?(@com_stud)
  end
end
