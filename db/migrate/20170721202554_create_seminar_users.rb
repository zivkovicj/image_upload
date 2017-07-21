class CreateSeminarUsers < ActiveRecord::Migration[5.0]
  def change
    create_join_table :seminar, :users do |t|
      t.references :seminar, foreign_key: true
      t.references :user, foreign_key: true
      t.integer  :teach_request
      t.integer  :learn_request
      t.integer  :pref_request
      t.boolean  :present
      t.integer  :consulting_stars
      
      t.timestamps
    end
  end
end
