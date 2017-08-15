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
        @seminar.objective_seminars.create(:objective => @already_preassign_to_main, :pretest => 1)
        @seminar.objective_seminars.create(:objective => @main_objective, :pretest => 1)
        
        assert_not @seminar.objective_is_pretest(@objective_40)
        assert_not @seminar.objective_is_pretest(@objective_50)
        assert @seminar.objective_is_pretest(@objective_80)
        assert @seminar.objective_is_pretest(@already_preassign_to_main)
        assert @seminar.objective_is_pretest(@main_objective)
        
        #Student 1
        @objective_40.objective_students.find_by(:student => @student_1).update(:points => 60)
        @objective_50.objective_students.find_by(:student => @student_1).update(:points => 80)
        @objective_80.objective_students.find_by(:student => @student_1).update(:points => 80)
        @already_preassign_to_main.objective_students.find_by(:student => @student_1).update(:points => 60)
        assert_not @seminar.all_pretest_objectives(@student_1).include?(@objective_40)
        assert_not @seminar.all_pretest_objectives(@student_1).include?(@objective_50)
        assert @seminar.all_pretest_objectives(@student_1).include?(@already_preassign_to_main)
        assert_not @seminar.all_pretest_objectives(@student_1).include?(@main_objective)
        assert @seminar.all_pretest_objectives(@student_1).include?(@objective_80)
        
        #Student 2
        @objective_40.objective_students.find_by(:student => @student_2).update(:points => 60)
        @objective_50.objective_students.find_by(:student => @student_2).update(:points => 80)
        @objective_80.objective_students.find_by(:student => @student_2).update(:points => 100)
        @already_preassign_to_main.objective_students.find_by(:student => @student_2).update(:points => 80)
        assert_not @seminar.all_pretest_objectives(@student_2).include?(@objective_40)
        assert_not @seminar.all_pretest_objectives(@student_2).include?(@objective_50)
        assert @seminar.all_pretest_objectives(@student_2).include?(@already_preassign_to_main)
        assert @seminar.all_pretest_objectives(@student_2).include?(@main_objective)
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
    
    test "quiz without questions" do
        @bad_objective = Objective.create(:name => "Bad Objective")
        @bad_objective.objective_seminars.create(:seminar => @seminar, :pretest => 1)
        
        go_to_first_period
        click_on(@bad_objective.name)
        
        assert_no_text("Question: 1")
    end
    
    test "quiz with questions" do
        @seminar.objective_seminars.find_by(:objective => @objective_10).update(:pretest => 1)
        go_to_first_period
        begin_quiz
        
        assert_text("Question: 1")
    end
    
end