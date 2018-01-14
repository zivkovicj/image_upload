class MoveDueDateToSeminar < ActiveRecord::Migration[5.0]
  def change
    remove_column    :checkpoints, :due_date
    add_column       :seminars, :checkpoint_due_dates, :text
  end
end
