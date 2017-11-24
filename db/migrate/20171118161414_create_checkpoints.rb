class CreateCheckpoints < ActiveRecord::Migration[5.0]
  def change
    create_table  :checkpoints do |t|
      t.integer   :goal_student_id
      t.integer   :number
      t.string    :action
      t.string    :achievement
      t.text      :comments
      t.date      :due_date
      
      t.timestamps
    end
  end
end
