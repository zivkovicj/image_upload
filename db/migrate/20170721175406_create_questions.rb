class CreateQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :questions do |t|
      t.text :prompt
      t.string :extent
      t.references :user, foreign_key: true
      t.references :label, foreign_key: true
      t.text :correct_answers
      t.string :choice_0
      t.string :choice_1
      t.string :choice_2
      t.string :choice_3
      t.string :choice_4
      t.string :choice_5
      t.references :picture, foreign_key: true

      t.timestamps
    end
  end
end
