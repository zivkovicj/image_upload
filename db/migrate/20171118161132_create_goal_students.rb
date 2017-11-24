class CreateGoalStudents < ActiveRecord::Migration[5.0]
  def change
    create_table :goal_students do |t|
      t.integer     :term
      t.references  :goal, foreign_key: true
      t.references  :user, foreign_key: true
      t.references  :seminar, foreign_key: true
      t.integer     :target
      t.boolean     :approved
      
      t.timestamps
    end
    
    add_index :goal_students, [:goal_id, :user_id]
  end
end
