class AddProgressToQuizzes < ActiveRecord::Migration[5.0]
  def change
    add_column  :quizzes, :progress, :integer
  end
end
