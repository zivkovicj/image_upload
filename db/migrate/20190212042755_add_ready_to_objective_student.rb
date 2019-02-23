class AddReadyToObjectiveStudent < ActiveRecord::Migration[5.0]
  def change
    add_column  :objective_students, :ready, :boolean, null: false, default: false
    add_column  :objective_seminars, :students_needed, :integer
  end
end
