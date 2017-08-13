require 'test_helper'

class NewQuizTest < ActionDispatch::IntegrationTest
    
    def setup
        setup_users()
        setup_labels()
        setup_objectives()
        setup_questions()
        setup_scores()
    end
    
    test "create new quiz" do
        old_quiz_count = Quiz.count
        old_riposte_count = Riposte.count
        
        setup_consultancies()
        
        go_to_first_period
        begin_quiz
        
        @new_quiz = Quiz.last
        assert_equal @new_quiz.student, @student_2
        assert_equal @new_quiz.objective, @objective_10
        assert_equal old_quiz_count + 1, Quiz.count
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
        
        assert_text("Your Scores in All Objectives")
        @new_quiz.reload
        assert_not_nil @new_quiz.total_score
        @new_quiz.ripostes.each do |riposte|
            assert_not riposte.tally.blank?
            assert_not_nil riposte.tally
        end
        assert @student_2.quizzes.include?(@new_quiz)
    end
    
    test "take fill-in quiz" do
        go_to_first_period
        
        click_on("Fill-in Questions Only")
        fill_in "stud_answer", with: "Yes"
        click_on "Next Question"
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
        fill_in "stud_answer", with: "course of"
        click_on "Next Question"
        
        @new_quiz = Quiz.last
        assert_equal 57, @new_quiz.total_score
        assert @student_2.quizzes.include?(@new_quiz)
        
    end
    
    test "100_total_score" do
        
        setup_consultancies()
        
        go_to_first_period
        begin_quiz
        
        6.times do |riposte|
            this_id = current_path[/\d+/].to_i
            @riposte = Riposte.find(this_id)
            @question = @riposte.question
            correct_answer = @question.correct_answers.first
            choose("choice_bubble_#{correct_answer}")
            click_on("Next Question")
        end
        
        @new_quiz = Quiz.last
        assert_equal 100, @new_quiz.total_score
    end
    
end