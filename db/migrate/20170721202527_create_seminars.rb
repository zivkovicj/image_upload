class CreateSeminars < ActiveRecord::Migration[5.0]
  def change
    create_table :seminars do |t|
      t.string :name
      t.references :user, foreign_key: true
      t.integer :consultantThreshold
      
      t.timestamps
    end
  end
end
