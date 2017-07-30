class CreateStudentTeams < ActiveRecord::Migration[5.0]
  def change
    create_table :student_teams, id:false do |t|
      t.integer   :student_id
      t.integer   :team_id
      t.timestamps
    end
    
    add_index  :student_teams, [:student_id, :team_id]
  end
end
