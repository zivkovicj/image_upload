class CreateObjectiveUsers < ActiveRecord::Migration[5.0]
  def change
    create_join_table :objectives, :users do |t|
      t.references  :objectives, foreign_key: true
      t.references  :users, foreign_key: true
      t.integer :score
      t.integer :unlocked
      t.timestamps
    end
  end
end
