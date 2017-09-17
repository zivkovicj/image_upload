class AddBenchmarkToSeminarStudents < ActiveRecord::Migration[5.0]
  def change
    add_column :seminar_students, :benchmark, :integer
  end
end
