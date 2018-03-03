class RemoveBenchmarkStarsFromStudents < ActiveRecord::Migration[5.0]
  def change
    remove_column :seminar_students, :benchmark, :integer
  end
end
