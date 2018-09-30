class AddDurationToConsultancy < ActiveRecord::Migration[5.0]
  def change
    add_column  :consultancies, :duration, :string
    add_column  :seminar_students, :last_consultant_day, :date
  end
end
