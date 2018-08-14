class RenamePoints < ActiveRecord::Migration[5.0]
  def change
    rename_column :objective_students, :points, :points_all_time
    remove_column :objective_students, :current_scores
    add_column    :objective_students, :points_this_term, :integer
  end
end
