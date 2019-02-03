class CreateWorksheets < ActiveRecord::Migration[5.0]
  def change
    create_table :worksheets do |t|
      t.string :name
      t.string :uploaded_file
      t.string :extent
      t.references :user, foreign_key: true
      
      t.timestamps
    end
  end
end
