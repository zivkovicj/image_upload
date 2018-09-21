require 'test_helper'

class QuizzesAvailableTest < ActionDispatch::IntegrationTest

    def setup
        setup_users
        setup_schools
        setup_labels
        setup_seminars
        setup_objectives
        setup_questions
        setup_scores
        setup_goals
        
        @test_os = @objective_10.objective_students.find_by(:user => @student_2)
    end
    
    def begin_quiz(which_key)
        click_on("Quizzes")
        find("##{which_key}_#{@objective_10.id}").click
    end
    
    test "has no keys" do
        go_to_first_period
        click_on("Quizzes")
        
        assert_no_selector('a', :id => "teacher_granted_#{@objective_10.id}")
    end
    
    def try_quiz_twice(which_key)
        @test_os.update(:teacher_granted_keys => 0, :pretest_keys => 0, :dc_keys => 0)
        set_specific_score(@test_os.user, @test_os.objective, 0)
        
        @test_os.update(:"#{which_key}_keys" => 2)
        old_quiz_count = Quiz.count
        
        go_to_first_period
        begin_quiz(which_key)
        
        assert_text("Question: 1")
        
        answer_quiz_randomly
        click_on("Try this quiz again")
        
        assert_equal 0, @test_os.reload.read_attribute(:"#{which_key}_keys")
        @quiz = Quiz.last
        assert_equal which_key, @quiz.origin
        
        answer_quiz_randomly
        
        assert_equal old_quiz_count + 2, Quiz.count
        assert_no_text("Try this quiz again")
    end
    
    test "teacher keys" do
        try_quiz_twice("teacher_granted")
    end
    
    test "pretest keys" do
        try_quiz_twice("pretest")
    end
    
    test "quiz without questions" do
        @bad_objective = Objective.create(:name => "Bad Objective")
        @bad_objective.objective_seminars.create(:seminar => @seminar, :pretest => 1)
        @bad_objective.objective_students.find_by(:user => @student_2).update(:teacher_granted_keys => 2)
        
        go_to_first_period
        click_on("Quizzes")
        click_on(@bad_objective.name)
        
        assert_no_text("Question: 1")
    end
    
    test "quiz with questions" do
        @test_os.update(:teacher_granted_keys => 2)
        set_specific_score(@test_os.user, @test_os.objective, 4)
        set_specific_score(@student_2, @objective_10, 2)
        
        go_to_first_period
        begin_quiz("teacher_granted")
        
        assert_text("Question: 1")
    end
    
    test "unfinished quizzes" do
        @seminar.objective_seminars.update_all(:pretest => 0)
        @seminar.objective_seminars.find_by(:objective => @objective_10).update(:pretest => 1)
        @student_2.objective_students.find_by(:objective => @objective_10).update(:pretest_keys => 2)
        set_specific_score(@student_2, @objective_10, 0)
       
        go_to_first_period
        click_on("Quizzes")
        assert_no_text("Unfinished Quizzes")
        assert_text("Pretest Objectives")
        find("#pretest_#{@objective_10.id}").click
       
        3.times do |n|
            assert_text("Question: #{n+1}")
            choose("choice_bubble_1")
            click_on("Next Question")
        end
       
        click_on("Log out")
       
        go_to_first_period
        click_on("Quizzes")
        assert_text("Unfinished Quizzes")
        assert_no_text("Pretest Objectives")
        click_link("#{@objective_10.name}", match: :first) # This time the first link should go to the unfinished quiz
        assert_text("Question: 4")                      # A little redundant with the next line, but this assertion is the most important one
       
        7.times do |n|
            assert_text("Question: #{n+4}")
            choose("choice_bubble_1")
            click_on("Next Question")
        end
       
       assert_text("This Score:")
    end
    
    test "not ready for quiz" do
        @test_os.update(:pretest_keys => 2)
        set_specific_score(@test_os.user, @test_os.objective, 2)
        main_assign_os = @objective_20.objective_students.find_by(:user => @student_2)
        main_assign_os.update(:pretest_keys => 2)
        
        go_to_first_period
        click_on("Quizzes")
        
        assert_no_selector('a', :id => "pretest_#{@objective_20.id}")
    end
    
    test "yes ready for quiz" do
        main_assign_os = @objective_20.objective_students.find_by(:user => @student_2)
        main_assign_os.update(:pretest_keys => 2)
        @objective_20.preassigns.each do |obj|
            obj.objective_students.find_or_create_by(:user => @student_2).update(:points_all_time => 8)
        end
        
        go_to_first_period
        click_on("Quizzes")
        
        assert_selector('a', :id => "pretest_#{@objective_20.id}")
    end
    
    test "erase oldest quiz if student has 6" do
        @test_os.update(:teacher_granted_keys => 6)
        set_specific_score(@test_os.user, @test_os.objective, 8)
        go_to_first_period
        begin_quiz("teacher_granted")
        
        should_array = [1,2,3,4,5,5,5,5]
        8.times do |y|
            @test_os.reload.update_keys("teacher_granted", 1)
            assert_equal should_array[y], @student_2.quizzes.where(:objective => @objective_10).count
            answer_quiz_randomly
            click_on ("Try this quiz again")
        end
    end
    
end