class CreatePictures < ActiveRecord::Migration
  def change
    create_table :pictures do |t|
      t.string :name
      t.references :labels, foreign_key: true
      t.references :questions, foreign_key: true
      t.string :image
      
      t.timestamps null: false
    end
  end
end
