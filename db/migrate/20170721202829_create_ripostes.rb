class CreateRipostes < ActiveRecord::Migration[5.0]
  def change
    create_table :ripostes do |t|
      t.references  :quiz, foreign_key: true
      t.references  :question, foreign_key: true
      t.integer  :tally
      t.integer  :position
      t.string  :stud_answer
      t.integer  :poss
      t.timestamps
    end
  end
end
