class CreateConsultancies < ActiveRecord::Migration[5.0]
  def change
    create_table :consultancies do |t|
      t.references :seminar, foreign_key: true
      
      t.timestamps
    end
  end
end
