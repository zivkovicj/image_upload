class AddExtentToGoals < ActiveRecord::Migration[5.0]
  def change
    add_column :goals, :extent, :string
    add_reference :goals, :user, foreign_key: true
  end
end
