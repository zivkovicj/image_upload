class CreateObjectiveSeminars < ActiveRecord::Migration[5.0]
  def change
    create_table :objective_seminars do |t|
      t.references :seminar, foreign_key: true
      t.references :objective, foreign_key: true
      t.integer  :priority
      t.timestamps
    end
    
    add_index  :objective_seminars, [:objective_id, :seminar_id]
  end
end
