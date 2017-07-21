json.array!(@questions) do |question|
  json.extract! question, :id, :prompt, :extent, :user_id, :label_id, :correct_answers, :choice_0, :choice_1, :choice_2, :choice_3, :choice_4, :choice_5, :picture_id
  json.url question_url(question, format: :json)
end
