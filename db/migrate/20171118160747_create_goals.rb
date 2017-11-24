class CreateGoals < ActiveRecord::Migration[5.0]
  def change
    create_table :goals do |t|
      t.string :action_0
      t.string :action_1
      t.string :action_2
      t.string :action_3
      t.string :action_4
      t.string :action_5
      t.string :action_6
      t.string :action_7
      
      t.string :second_action_0
      t.string :second_action_1
      t.string :second_action_2
      
      t.integer :style
      t.string :name
      
      t.timestamps
    end
  end
end
