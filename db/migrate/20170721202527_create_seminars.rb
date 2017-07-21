class CreateSeminars < ActiveRecord::Migration[5.0]
  def change
    create_table :seminars do |t|
      t.string :name
      t.integer :teacher_id
      t.integer :consultantThreshold
      
      t.timestamps
    end
  end
end
