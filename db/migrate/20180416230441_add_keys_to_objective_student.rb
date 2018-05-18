class AddKeysToObjectiveStudent < ActiveRecord::Migration[5.0]
  def change
    add_column    :objective_students, :pretest_keys, :integer
    add_column    :objective_students, :dc_keys, :integer
    add_column    :objective_students, :teacher_granted_keys, :integer
  end
end
