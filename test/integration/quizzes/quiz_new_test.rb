require 'test_helper'

class NewQuizTest < ActionDispatch::IntegrationTest
    
    def setup
        setup_users
        setup_schools
        setup_seminars
        setup_labels
        setup_objectives
        setup_questions
        setup_scores
        setup_goals
        
        @student_2.objective_students.find_by(:objective => @objective_10).update(:points => 2)
        @test_obj_stud = @objective_10.objective_students.find_by(:user => @student_2)
        @test_obj_stud.update(:teacher_granted_keys => 2)
    end
    
    def begin_quiz
        find("#navribbon_quizzes").click
        find("#teacher_granted_#{@objective_10.id}").click
    end

    def answer_question_correctly
        this_id = current_path[/\d+/].to_i
        @riposte = Riposte.find(this_id)
        @question = @riposte.question
        correct_answer = @question.correct_answers.first
        choose("choice_bubble_#{correct_answer}")
    end
    
    def answer_question_incorrectly
        this_id = current_path[/\d+/].to_i
        @riposte = Riposte.find(this_id)
        @question = @riposte.question
        incorrect_answer = (@question.correct_answers.first.to_i) + 1
        choose("choice_bubble_#{incorrect_answer}")
    end
    
    test "setup quiz" do
        old_quiz_count = Quiz.count
        old_riposte_count = Riposte.count
        score_box = [0,0,0,0]
        score_box[@seminar.term_for_seminar] = 2
        ObjectiveStudent.find_by(:user => @student_2, :objective => @objective_10).update(:current_scores => score_box)
        
        go_to_first_period
        begin_quiz
        @new_quiz = Quiz.last
        assert_equal @new_quiz.user, @student_2
        assert_equal @new_quiz.objective, @objective_10
        assert_equal old_quiz_count + 1, Quiz.count
        assert_equal 2, @new_quiz.old_stars
        
        new_riposte_count = @new_quiz.ripostes.count
        assert new_riposte_count > 0
        assert_equal old_riposte_count + new_riposte_count, Riposte.count
    end
    
    test "take multiple-choice quiz" do
        setup_consultancies
        go_to_first_period
        begin_quiz
        assert_no_text("Your Scores in All Objectives")
        @new_quiz = Quiz.last
        assert @new_quiz.ripostes.count > 0
        assert_nil @new_quiz.total_score
        @new_quiz.ripostes.each do |riposte|
            assert riposte.tally.blank?
            assert_nil riposte.tally
        end
        answer_quiz_randomly
        click_on("Back to Your Class Page")
        
        assert_text("Your Scores in All Objectives")
        @new_quiz.reload
        assert_not_nil @new_quiz.total_score
        @new_quiz.ripostes.each do |riposte|
            assert_not riposte.tally.blank?
            assert_not_nil riposte.tally
        end
        assert @student_2.quizzes.include?(@new_quiz)
    end
    
    test "take fill in quiz" do
        fill_in_objective = Objective.find_by(:name => "Fill-in Questions Only")
        fill_in_objective.objective_students.find_by(:user => @student_2).update(:teacher_granted_keys => 2, :points => 4)
        go_to_first_period
        
        find("#navribbon_quizzes").click
        find("#teacher_granted_#{fill_in_objective.id}").click
        @quiz = Quiz.last
        fill_in "stud_answer", with: "Yes"
        click_on "Next Question"
        @quiz.reload
        assert_equal 1, @quiz.progress
        fill_in "stud_answer", with: "No"
        click_on "Next Question"
        fill_in "stud_answer", with: "yes"
        click_on "Next Question"
        fill_in "stud_answer", with: "yes!"
        click_on "Next Question"
        fill_in "stud_answer", with: "ofcourse"
        click_on "Next Question"
        fill_in "stud_answer", with: "ofco urse"
        click_on "Next Question"
        @quiz.reload
        assert_equal 6, @quiz.progress
        fill_in "stud_answer", with: "course of"
        click_on "Next Question"
        
        @new_quiz = Quiz.last
        assert_equal 57, @new_quiz.total_score
        assert @student_2.quizzes.include?(@new_quiz)
    end
    
    test "100 total score" do
        @test_obj_stud.update(:dc_keys => 2)
        setup_consultancies
        
        go_to_first_period
        begin_quiz
        
        10.times do
            answer_question_correctly
            click_on("Next Question")
        end
        
        @new_quiz = Quiz.last
        assert_equal 100, @new_quiz.total_score
        @test_obj_stud.reload
        assert_equal 0, @test_obj_stud.teacher_granted_keys
        assert_equal 0, @test_obj_stud.dc_keys
    end
    
    test "current score" do
        @test_obj_stud.update(:points => 1, :teacher_granted_keys => 2, :current_scores => [1,1,nil,nil])
        
        # First try on quiz student scores 3 stars. An improvement of 2 stars.
        go_to_first_period
        begin_quiz
        3.times do
            answer_question_correctly
            click_on("Next Question")
        end
        7.times do
            answer_question_incorrectly
            click_on("Next Question")
        end
        
        @test_obj_stud.reload
        assert_equal 3, @test_obj_stud.points
        assert_equal [1,3,nil,nil], @test_obj_stud.current_scores
        
        # Second try on quiz student scores 8 stars. An improvement of 5 stars.
        click_on("Try this quiz again")
        8.times do
            answer_question_correctly
            click_on("Next Question")
        end
        2.times do
            answer_question_incorrectly
            click_on("Next Question")
        end
        
        @test_obj_stud.reload
        assert_equal 8, @test_obj_stud.points
        assert_equal [1,8,nil,nil], @test_obj_stud.current_scores
    end
    
    test "quizzed better last term" do
        @test_obj_stud.update(:points => 8, :teacher_granted_keys => 2, :current_scores => [8,4,nil,nil])
        
        go_to_first_period
        begin_quiz
        5.times do
            answer_question_correctly
            click_on("Next Question")
        end
        5.times do
            answer_question_incorrectly
            click_on("Next Question")
        end
        
        @test_obj_stud.reload
        assert_equal 8, @test_obj_stud.points
        assert_equal [8,5,nil,nil], @test_obj_stud.current_scores
    end
    
    test "quizzed better this term" do
        @test_obj_stud.update(:points => 8, :teacher_granted_keys => 2, :current_scores => [8,7,nil,nil])
        
        go_to_first_period
        begin_quiz
        5.times do
            answer_question_correctly
            click_on("Next Question")
        end
        5.times do
            answer_question_incorrectly
            click_on("Next Question")
        end
        
        @test_obj_stud.reload
        assert_equal 8, @test_obj_stud.points
        assert_equal [8,7,nil,nil], @test_obj_stud.current_scores
    end
    
    test "pretest" do
        @test_obj_stud.update(:teacher_granted_keys => 0, :pretest_keys => 2, :current_scores => [1,nil,nil,nil])
        @first_mainassign = @objective_10.mainassigns.first
        @mainassign_os = @student_2.objective_students.find_by(:objective => @first_mainassign)
        @mainassign_os.update(:teacher_granted_keys => 0, :pretest_keys => 2, :points => 0)
        
        go_to_first_period
        find("#navribbon_quizzes").click
        find("#pretest_#{@objective_10.id}").click
        
        # 1 times do
        answer_question_correctly
        click_on("Next Question")

        9.times do
            answer_question_incorrectly
            click_on("Next Question")
        end
        
        # Doesn't take the keys yet, because student still has another try
        @test_obj_stud.reload
        assert_equal 1, @test_obj_stud.pretest_keys
        assert_equal 1, @test_obj_stud.pretest_score
        assert_equal 2, @test_obj_stud.points  #Stays the same because it didn't increase from the previous score
        assert_equal [1,nil,nil,nil], @test_obj_stud.current_scores  #Doesn't change
        assert_equal 2, @mainassign_os.reload.pretest_keys  
        
        click_on("Try this quiz again")
        3.times do
            answer_question_correctly
            click_on("Next Question")
        end
        7.times do
            answer_question_incorrectly
            click_on("Next Question")
        end
        
        # Now it takes the pretest keys for the post-requisites to spare the student the struggle of taking a pre-test that she is doomed to fail.
        @test_obj_stud.reload
        assert_equal 0, @test_obj_stud.pretest_keys
        assert_equal 3, @test_obj_stud.pretest_score
        assert_equal 3, @test_obj_stud.points
        assert_equal 0, @mainassign_os.reload.pretest_keys   
    end
    
    
end