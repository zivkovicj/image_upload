require 'test_helper'

class QuizzesAvailableTest < ActionDispatch::IntegrationTest

    def setup
        setup_users
        setup_labels
        setup_seminars
        setup_objectives
        setup_questions
        setup_scores
    end

    test "available from pretest" do
        @seminar.objective_seminars.find_by(:objective => @objective_10).update(:pretest => 1)
        @seminar.objective_seminars.find_by(:objective => @objective_40).update(:pretest => 0)
        @seminar.objective_seminars.find_by(:objective => @objective_50).update(:pretest => 0)
        @seminar.objective_seminars.create(:objective => @objective_80, :pretest => 1)
        @seminar.objective_seminars.create(:objective => @alreadyPreassignedToMainMain, :pretest => 1)
        @seminar.objective_seminars.create(:objective => @mainMainAssign, :pretest => 1)
        
        assert_not @seminar.objective_is_pretest(@objective_40)
        assert_not @seminar.objective_is_pretest(@objective_50)
        assert @seminar.objective_is_pretest(@objective_80)
        assert @seminar.objective_is_pretest(@alreadyPreassignedToMainMain)
        assert @seminar.objective_is_pretest(@mainMainAssign)
        
        #Student 1
        @objective_40.objective_students.find_by(:student => @student_1).update(:points => 60)
        @objective_50.objective_students.find_by(:student => @student_1).update(:points => 80)
        @objective_80.objective_students.find_by(:student => @student_1).update(:points => 80)
        @alreadyPreassignedToMainMain.objective_students.find_by(:student => @student_1).update(:points => 60)
        assert_not @seminar.all_pretest_objectives(@student_1).include?(@objective_40)
        assert_not @seminar.all_pretest_objectives(@student_1).include?(@objective_50)
        assert @seminar.all_pretest_objectives(@student_1).include?(@alreadyPreassignedToMainMain)
        assert_not @seminar.all_pretest_objectives(@student_1).include?(@mainMainAssign)
        assert @seminar.all_pretest_objectives(@student_1).include?(@objective_80)
        
        #Student 2
        @objective_40.objective_students.find_by(:student => @student_2).update(:points => 60)
        @objective_50.objective_students.find_by(:student => @student_2).update(:points => 80)
        @objective_80.objective_students.find_by(:student => @student_2).update(:points => 100)
        @alreadyPreassignedToMainMain.objective_students.find_by(:student => @student_2).update(:points => 80)
        assert_not @seminar.all_pretest_objectives(@student_2).include?(@objective_40)
        assert_not @seminar.all_pretest_objectives(@student_2).include?(@objective_50)
        assert @seminar.all_pretest_objectives(@student_2).include?(@alreadyPreassignedToMainMain)
        assert @seminar.all_pretest_objectives(@student_2).include?(@mainMainAssign)
        assert_not @seminar.all_pretest_objectives(@student_2).include?(@objective_80)
        
        assert @seminar.all_pretest_objectives(@student_2).include?(@objective_10)
        go_to_first_period
        begin_quiz
        answer_quiz_randomly
        
        assert @seminar.all_pretest_objectives(@student_2).include?(@objective_10)
        begin_quiz
        answer_quiz_randomly
        
        assert_not @seminar.all_pretest_objectives(@student_2).include?(@objective_10)
    end
    
    test "available from desk consultants" do
        assert_not @student_2.desk_consulted_objectives(@seminar).include?(@objective_10)
        
        setup_consultancies
        assert @student_2.desk_consulted_objectives(@seminar).include?(@objective_10)
        
        @student_2.objective_students.find_by(:objective => @objective_10).update(:points => 80)
        assert @student_2.desk_consulted_objectives(@seminar).include?(@objective_10)
        
        @student_2.objective_students.find_by(:objective => @objective_10).update(:points => 100)
        assert_not @student_2.desk_consulted_objectives(@seminar).include?(@objective_10)
    end
    
end