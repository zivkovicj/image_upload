require 'test_helper'

class NewQuizTest < ActionDispatch::IntegrationTest
    
    def setup
        setup_users
        setup_seminars
        setup_labels
        setup_objectives
        setup_questions
        setup_scores
        setup_goals
        
        @student_2.objective_students.find_by(:objective => @objective_10).update(:points => 2)
        @test_os = @objective_10.objective_students.find_by(:user => @student_2)
    end
    
    def begin_quiz
        find("#navribbon_quizzes").click
        find("#teacher_granted_#{@objective_10.id}").click
    end
    
    test "fail pretest" do
        @test_os.update(:teacher_granted_keys => 0, :pretest_keys => 2)
        @first_mainassign = @objective_10.mainassigns.first
        @mainassign_os = @student_2.objective_students.find_by(:objective => @first_mainassign)
        @mainassign_os.update(:teacher_granted_keys => 0, :pretest_keys => 2)
        
        go_to_first_period
        find("#navribbon_quizzes").click
        find("#pretest_#{@objective_10.id}").click
        10.times do
            answer_question_incorrectly
            click_on("Next Question")
        end
        
        # Doesn't take the keys yet, because student still has another try
        
        assert_equal 1, @test_os.reload.pretest_keys
        assert_equal 2, @mainassign_os.reload.pretest_keys  
        
        click_on("Try this quiz again")
        10.times do
            answer_question_incorrectly
            click_on("Next Question")
        end
        
        # Now it takes the pretest keys for the post-requisites to spare the student the struggle of taking a pre-test that she is doomed to fail.
        
        assert_equal 0, @test_os.reload.pretest_keys
        assert_equal 0, @mainassign_os.reload.pretest_keys   
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
        @test_os.update(:teacher_granted_keys => 2)
        old_quiz_count = Quiz.count
        old_riposte_count = Riposte.count
        
        setup_consultancies
        
        go_to_first_period
        begin_quiz
        @new_quiz = Quiz.last
        assert_equal @new_quiz.user, @student_2
        assert_equal @new_quiz.objective, @objective_10
        assert_equal old_quiz_count + 1, Quiz.count
        new_riposte_count = @new_quiz.ripostes.count
        assert new_riposte_count > 0
        assert_equal old_riposte_count + new_riposte_count, Riposte.count
    end
    
    test "take multiple-choice quiz" do
        @test_os.update(:teacher_granted_keys => 2)
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
        fill_in_objective.objective_students.find_by(:user => @student_2).update(:teacher_granted_keys => 2)
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
        assert_equal 6, @new_quiz.total_score
        assert @student_2.quizzes.include?(@new_quiz)
    end
    
    test "100 total score" do
        @test_os.update(:teacher_granted_keys => 2, :dc_keys => 2)
        setup_consultancies
        
        go_to_first_period
        begin_quiz
        
        10.times do
            answer_question_correctly
            click_on("Next Question")
        end
        
        @new_quiz = Quiz.last
        assert_equal 10, @new_quiz.total_score
        @test_os.reload
        assert_equal 0, @test_os.teacher_granted_keys
        assert_equal 0, @test_os.dc_keys
    end
    
    test "add to total stars" do
        @ss = SeminarStudent.find_by(:user => @student_2, :seminar => @seminar)
        @student_2.objective_students.find_by(:objective => @objective_10).update(:points => 1, :teacher_granted_keys => 2)
        old_stars = @student_2.total_stars(@seminar)
        
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
        
        @ss.reload
        assert_equal old_stars + 2, @student_2.total_stars(@seminar)
        
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
        
        @ss.reload
        assert_equal old_stars + 7, @student_2.total_stars(@seminar)
        
    end
    
    
    
end