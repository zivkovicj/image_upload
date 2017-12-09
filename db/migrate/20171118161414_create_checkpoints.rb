class CreateCheckpoints < ActiveRecord::Migration[5.0]
  def change
    create_table  :checkpoints do |t|
      t.integer   :goal_student_id
      t.string    :action
      t.integer    :achievement
      t.text      :teacher_comment
      t.text      :student_comment
      t.date      :due_date
      
      t.timestamps
    end
  end
end
