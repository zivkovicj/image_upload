class CreateObjectiveStudents < ActiveRecord::Migration[5.0]
  def change
    create_table :objective_students do |t|
      t.references  :objective, foreign_key: true
      t.references  :user, foreign_key: true
      t.integer :points
      t.integer :unlocked
      t.timestamps
    end
    
    add_index :objective_students, [:objective_id, :user_id]
  end
end
