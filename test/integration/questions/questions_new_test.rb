require 'test_helper'

class QuestionsNewTest < ActionDispatch::IntegrationTest

    def setup
        setup_labels()
        @teacher_user = users(:archer)
        
        @new_choice = [["Blubber", "Scoober Doofus", "Hardunkinchud @ Aliciousness", 
            "{The Player formerly known as Mousecop}", "Red Grange", "1073514"],
            ["Yep.","Nope."],
            ["Nep.","Yope."],
            ["Meep","Yeep","Bleep","Creep"],
            ["Boop","Doop","Goop","Shoop","Stoop"]]
        @new_prompt = ["How many Scoobers can a Scoober Doof?",
            "Are there two questions?",
            "Are there three?",
            "Are there four?",
            "Surely there can't be five!"]
    end

    test "create new question" do
        oldQuestionCount = Question.count
        
        capybara_teacher_login()
        click_on("Create New Questions")
        assert_selector('input', :id => "label_#{@admin_l.id}")
        assert_selector('input', :id => "label_#{@user_l.id}")
        assert_selector('input', :id => "label_#{@other_l_pub.id}")
        assert_no_selector('input', :id => "label_#{@other_l_priv.id}")
        
        choose("label_#{@user_l.id}")
        @new_prompt.each_with_index do |prompt, index|
            fill_in "prompt_#{index+1}", with: prompt
        end
        @new_choice.each_with_index do |array, index|
            array.each_with_index do |blap, index_2|
                fill_in "question_#{index+1}_choice_#{index_2}", with: blap
            end
        end
        choose("question_1_whichIsCorrect_2")
        choose("question_2_whichIsCorrect_0")
        click_on("Create These Questions")
        
        assert_equal oldQuestionCount + 5, Question.count
        
        Question.all[-5..-1].each_with_index do |question, index|
            assert_equal @new_prompt[index], question.prompt
            assert_equal "public", question.extent
            assert_equal @teacher_user, question.user
            assert_equal @user_l, question.label
            assert @user_l.questions.include?(question)
        end
        
        @new_question = Question.all[-5]
        assert @new_question.correct_answers.include?(@new_choice[0][2])
        6.times do |n|
            assert_equal @new_choice[0][n], @new_question.read_attribute("choice_#{n}")
            assert_not @new_question.correct_answers.include?(@new_choice[0][n]) if n != 2
        end
        @new_question_2 = Question.all[-4]
        assert_equal "Are there two questions?", @new_question_2.prompt
        assert_equal @new_choice[1][0], @new_question_2.choice_0
        assert_equal @new_choice[1][1], @new_question_2.choice_1
        assert @new_question_2.correct_answers.include?(@new_choice[1][0])
        assert_not @new_question_2.correct_answers.include?(@new_choice[1][1])
        
        # Need to assert redirection soon
    end
    
    test "dont create with empty prompt" do
        oldQuestionCount = Question.count
        
        capybara_teacher_login()
        click_on("Create New Questions")
        
        fill_in "prompt_1", with: @new_prompt[0]
        fill_in "prompt_3", with: @new_prompt[2]
        click_on("Create These Questions")
        
        assert_equal oldQuestionCount + 2, Question.count
    end
    
    test "default correct and label" do
        capybara_teacher_login()
        click_on("Create New Questions")
        
        fill_in "prompt_1", with: @new_prompt[0]
        fill_in "question_1_choice_0", with: @new_choice[0][0]
        click_on("Create These Questions")
        
        @new_question = Question.last
        assert_equal @unlabeled_l, @new_question.label
        assert @new_question.correct_answers.include?(@new_choice[0][0])
        assert_equal "Second Choice", @new_question.choice_1
    end
    
end