class CreateGoals < ActiveRecord::Migration[5.0]
  def change
    create_table :goals do |t|
      t.text    :actions
      
      t.integer :style
      t.string :name
      t.string :statement_stem
      
      t.timestamps
    end
  end
end
