require 'test_helper'

class NewQuizTest < ActionDispatch::IntegrationTest
    
    def setup
        @martha = students(:student_2)
        @objective = objectives(:objective_10)
        setup_labels()
        setup_objectives()
        setup_questions()
        setup_scores()
    end
    
    test "create new quiz" do
        old_quiz_count = Quiz.count
        old_riposte_count = Riposte.count
        
        setup_consultancies()
        
        capybara_student_login(@martha)
        click_on(@objective.name)
        
        @new_quiz = Quiz.last
        assert_equal @new_quiz.student, @martha
        assert_equal @new_quiz.objective, @objective
        assert_equal old_quiz_count + 1, Quiz.count
        new_riposte_count = @new_quiz.ripostes.count
        assert new_riposte_count > 0
        assert_equal old_riposte_count + new_riposte_count, Riposte.count
    end
    
    test "take quiz" do
        setup_consultancies()
        
        capybara_student_login(@martha)
        click_on(@objective.name)
        
        @new_quiz = Quiz.last
        assert @new_quiz.ripostes.count > 0
        assert_nil @new_quiz.total_score
        @new_quiz.ripostes.each do |riposte|
            assert riposte.tally.blank?
            assert_nil riposte.tally
        end
        
        assert_no_text("Your Scores in All Objectives")
        
        6.times do
            choose("choice_bubble_1")
            click_on("Next Question")
        end
        
        click_on("Back to Your Class Page")
        assert_text("Your Scores in All Objectives")
        
        @new_quiz = Quiz.last
        @new_quiz.reload
        assert_not_nil @new_quiz.total_score
        @new_quiz.ripostes.each do |riposte|
            assert_not riposte.tally.blank?
            assert_not_nil riposte.tally
        end
    end
    
    test "100_total_score" do
        
        setup_consultancies()
        
        capybara_student_login(@martha)
        click_on(@objective.name)
        
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