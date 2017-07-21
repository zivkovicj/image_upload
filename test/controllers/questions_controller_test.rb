require 'test_helper'

class QuestionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @question = questions(:one)
  end

  test "should get index" do
    get questions_url
    assert_response :success
  end

  test "should get new" do
    get new_question_url
    assert_response :success
  end

  test "should create question" do
    assert_difference('Question.count') do
      post questions_url, params: { question: { choice_0: @question.choice_0, choice_1: @question.choice_1, choice_2: @question.choice_2, choice_3: @question.choice_3, choice_4: @question.choice_4, choice_5: @question.choice_5, correct_answers: @question.correct_answers, extent: @question.extent, label_id: @question.label_id, picture_id: @question.picture_id, prompt: @question.prompt, user_id: @question.user_id } }
    end

    assert_redirected_to question_url(Question.last)
  end

  test "should show question" do
    get question_url(@question)
    assert_response :success
  end

  test "should get edit" do
    get edit_question_url(@question)
    assert_response :success
  end

  test "should update question" do
    patch question_url(@question), params: { question: { choice_0: @question.choice_0, choice_1: @question.choice_1, choice_2: @question.choice_2, choice_3: @question.choice_3, choice_4: @question.choice_4, choice_5: @question.choice_5, correct_answers: @question.correct_answers, extent: @question.extent, label_id: @question.label_id, picture_id: @question.picture_id, prompt: @question.prompt, user_id: @question.user_id } }
    assert_redirected_to question_url(@question)
  end

  test "should destroy question" do
    assert_difference('Question.count', -1) do
      delete question_url(@question)
    end

    assert_redirected_to questions_url
  end
end
