class AddExtentToGoal < ActiveRecord::Migration[5.0]
  
  def change
    add_column    :goal_students, :term, :integer
    add_column    :checkpoints, :sequence, :integer
    
    add_column    :goals, :extent, :string
    add_reference :goals, :user, foreign_key: true
  end
end
