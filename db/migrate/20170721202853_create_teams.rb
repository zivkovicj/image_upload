class CreateTeams < ActiveRecord::Migration[5.0]
  def change
    create_table :teams do |t|
      t.references  :consultancy, foreign_key: true
      t.references  :objective, foreign_key: true
      t.integer  :consultant_id
      t.integer  :bracket
      t.timestamps
    end
  end
end
