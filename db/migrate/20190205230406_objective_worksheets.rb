class ObjectiveWorksheets < ActiveRecord::Migration[5.0]
  def change
    create_table :objective_worksheets do |t|
      t.references  :objective, foreign_key: true
      t.references  :worksheet, foreign_key: true
      
      t.timestamps
    end
  end
end
