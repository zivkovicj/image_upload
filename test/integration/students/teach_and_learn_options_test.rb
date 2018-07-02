require 'test_helper'

class StudentsSearchTest < ActionDispatch::IntegrationTest
   
    def setup
        setup_users
        setup_schools
        setup_seminars
        setup_objectives
        setup_scores_and_commodities
    end
    
    test "teach options" do
        @student_1.objective_students.update_all(:points => 8)
        num_of_objectives = @seminar.objectives.count
        assert_equal num_of_objectives - 1, @student_1.teach_options(@seminar, @seminar.rank_objectives_by_need).count  # (-1) becaues one of the objectives has zero priority
        assert_not_equal @objective_10, @student_1.teach_options(@seminar, @seminar.rank_objectives_by_need)[0]
        
        @seminar.objective_seminars.find_by(:objective => @objective_10).update(:priority => 5)
        assert_equal @objective_10, @student_1.teach_options(@seminar, @seminar.rank_objectives_by_need)[0]
        assert @student_1.teach_options(@seminar, @seminar.rank_objectives_by_need).include?(@objective_20)
        
        @student_1.objective_students.find_by(:objective => @objective_20).update(:points => 2)
        assert_equal num_of_objectives - 2, @student_1.teach_options(@seminar, @seminar.rank_objectives_by_need).count
        assert_not @student_1.teach_options(@seminar, @seminar.rank_objectives_by_need).include?(@objective_20)

        
        15.times do |n|
            new_obj = Objective.create(:name => "Objective_#{n}")
            @seminar.objectives << new_obj
            @student_1.objective_students.find_by(:objective => new_obj).update(:points => 8)
        end
        assert_equal 10, @student_1.teach_options(@seminar, @seminar.rank_objectives_by_need).count
    end
    
    test "learn options" do
        mainassign = @objective_10.mainassigns.first
        
        @student_1.objective_students.find_by(:objective => @objective_10).update(:points => 2)
        assert_equal 1, @objective_10.mainassigns.count
        @student_1.objective_students.find_by(:objective => mainassign).update(:points => 2)
        assert @student_1.learn_options(@seminar, @seminar.rank_objectives_by_need).include?(@objective_10)
        assert_not @student_1.learn_options(@seminar, @seminar.rank_objectives_by_need).include?(mainassign)
        
        15.times do |n|
            new_obj = Objective.create(:name => "Objective_#{n}")
            @seminar.objectives << new_obj
            @student_1.objective_students.find_by(:objective => new_obj).update(:points => 2)
        end
        assert_equal 10, @student_1.learn_options(@seminar, @seminar.rank_objectives_by_need).count
        
        newest_obj = @seminar.objectives.last
        assert_not_equal newest_obj, @student_1.learn_options(@seminar, @seminar.rank_objectives_by_need)[0]
        @seminar.objective_seminars.find_by(:objective => newest_obj).update(:priority => 5)
        assert_equal newest_obj, @student_1.learn_options(@seminar, @seminar.rank_objectives_by_need)[0]
    end
    
end