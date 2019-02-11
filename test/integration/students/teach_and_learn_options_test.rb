require 'test_helper'

class StudentsSearchTest < ActionDispatch::IntegrationTest
   
    def setup
        setup_users
        setup_schools
        setup_seminars
        setup_objectives
        setup_scores
    end
    
    test "teach options" do
        @student_1.objective_students.update_all(:points_all_time => 8)
        num_of_objectives = @seminar.objectives.count
        assert_equal num_of_objectives - 1, 
            @student_1.teach_options(@seminar).count  # (-1) because one of the objectives has zero priority
        assert_not_equal @objective_10, @student_1.teach_options(@seminar)[0]
        
        @seminar.objective_seminars.find_by(:objective => @objective_10).update(:priority => 5)
        assert_equal @objective_10, @student_1.teach_options(@seminar)[0]
        assert @student_1.teach_options(@seminar).include?(@objective_20)
        
        set_specific_score(@student_1, @objective_20, 2)
        assert_equal num_of_objectives - 2, @student_1.teach_options(@seminar).count
        assert_not @student_1.teach_options(@seminar).include?(@objective_20)

        
        15.times do |n|
            new_obj = Objective.create(:name => "Objective_#{n}")
            @seminar.objectives << new_obj
            @student_1.quizzes.create(:objective => new_obj, :origin => "teacher_granted", :total_score => 8)
        end
        assert_equal 10, @student_1.teach_options(@seminar).count
    end
    
    test "learn options" do
        mainassign = @objective_10.mainassigns.first
        
        set_specific_score(@student_1, @objective_10, 2)
        assert_equal 1, @objective_10.mainassigns.count
        set_specific_score(@student_1, mainassign, 2)
        assert @student_1.learn_options(@seminar).include?(@objective_10)
        assert_not @student_1.learn_options(@seminar).include?(mainassign)
        
        15.times do |n|
            new_obj = Objective.create(:name => "Objective_#{n}")
            @seminar.objectives << new_obj
            @student_1.quizzes.create(:objective => new_obj, :origin => "teacher_granted", :total_score => 2)
        end
        assert_equal 10, @student_1.learn_options(@seminar).count
        
        @seminar.objective_seminars.update_all(:priority => 3)
        newest_obj = @seminar.objectives.last
        assert_not_equal newest_obj, @student_1.learn_options(@seminar)[0]
        @seminar.objective_seminars.find_by(:objective => newest_obj).update(:priority => 5)
        assert_equal newest_obj, @student_1.learn_options(@seminar)[0]
    end
    
end