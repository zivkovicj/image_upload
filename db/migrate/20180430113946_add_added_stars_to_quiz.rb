class AddAddedStarsToQuiz < ActiveRecord::Migration[5.0]
  def change
    add_column  :quizzes, :added_stars, :integer
    add_column  :quizzes, :origin, :string
  end
end
