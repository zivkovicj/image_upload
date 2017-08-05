require 'test_helper'

class QuestionsFormTest < ActionDispatch::IntegrationTest
    
    def setup
        setup_users()
        setup_labels()
        setup_questions()
        @newPrompt = "How many Scoobers can a Scoober Doof?"
        @new_choice = ["Blubber", "Scoober Doofus", "Hardunkinchud @ Aliciousness", 
            "{The Player formerly known as Mousecop}", "Red Grange", "1073514"]
    end
    
    test "edit other question" do
        capybara_login(@teacher_1)
        click_on('All Questions')
        click_on(@other_q_pub.shortPrompt)
        
        assert_text("You may only edit a question that you have created.")
        assert_no_selector('textarea', :id => "prompt", :visible => true)
        assert_no_selector('input', :id => "answer_1_edit", :visible => true)
        assert_no_selector('input', :id => "whichIsCorrect_whichIsCorrect_3", :visible => true)
    end
    
    test "edit admin question" do
        capybara_login(@teacher_1)
        click_on('All Questions')
        click_on(@admin_q.shortPrompt)
        
        assert_text("You may only edit a question that you have created.")
        assert_no_selector('textarea', :id => "prompt", :visible => true)
        assert_no_selector('input', :id => "answer_1_edit", :visible => true)
        assert_no_selector('input', :id => "whichIsCorrect_whichIsCorrect_3", :visible => true)
    end
    
    test "edit own question" do
        assert_not @user_q.correct_answers.include?("4")
        
        capybara_login(@teacher_1)
        click_on('All Questions')
        click_on(@user_q.shortPrompt)
        
        assert_no_text("You may only edit a question that you have created.")
        
        new_prompt = "Where do you park the car?"
        new_answer_choice = "In the harbor by Harvard"
        
        fill_in "prompt", with: new_prompt
        fill_in "choice_1_edit", with: new_answer_choice
        choose('question_whichIsCorrect_4')
        
        click_on("Save Changes")
        
        @user_q.reload
        assert_equal new_prompt, @user_q.prompt
        assert_equal new_answer_choice, @user_q.choice_1
        assert @user_q.correct_answers.include?("4")
    end
end