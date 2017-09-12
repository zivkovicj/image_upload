require 'test_helper'

class NewQuizTest < ActionDispatch::IntegrationTest
    
    def setup
        setup_users
        setup_seminars
        setup_labels
        setup_objectives
        setup_questions
        setup_scores
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
        
        setup_consultancies()
        
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
        go_to_first_period
        
        click_on("Fill-in Questions Only")
        @quiz = Quiz.last
        fill_in "stud_answer", with: "Yes"
        click_on "Next Question"
        @quiz.reload
        assert_equal 2, @quiz.progress
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
        assert_equal 7, @quiz.progress
        fill_in "stud_answer", with: "course of"
        click_on "Next Question"
        
        @new_quiz = Quiz.last
        assert_equal 6, @new_quiz.total_score
        assert @student_2.quizzes.include?(@new_quiz)
        
    end
    
    test "100_total_score" do
        setup_consultancies()
        
        go_to_first_period
        begin_quiz
        
        10.times do
            answer_question_correctly
            click_on("Next Question")
        end
        
        @new_quiz = Quiz.last
        assert_equal 10, @new_quiz.total_score
    end
    
    test "add to total stars" do
        @os = ObjectiveStudent.find_by(:user => @student_2, :objective => @objective_10)
        @os.update(:points => 1)
        @ss = SeminarStudent.find_by(:user => @student_2, :seminar => @seminar)
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