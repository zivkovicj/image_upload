class CreateQuizzes < ActiveRecord::Migration[5.0]
  def change
    create_table :quizzes do |t|
      t.references  :student, foreign_key: true
      t.references  :objective, foreign_key: true
      t.integer  :total_score
      t.timestamps
    end
  end
end
