class AddOldStarsToQuizzes < ActiveRecord::Migration[5.0]
  def change
    add_column  :quizzes, :old_stars, :integer
    remove_column  :quizzes, :added_stars, :integer
  end
end
