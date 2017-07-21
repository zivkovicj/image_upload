class CreateLabelObjectives < ActiveRecord::Migration[5.0]
  def change
    create_table :label_objectives do |t|
      t.references  :objective, foreign_key: true
      t.references  :label, foreign_key: true
      t.integer  :quantity
      t.integer  :point_value
      t.timestamps
    end
  end
end
