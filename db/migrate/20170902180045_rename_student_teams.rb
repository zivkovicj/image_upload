class RenameStudentTeams < ActiveRecord::Migration[5.0]
  def up
    rename_table  :student_teams, :teams_users
  end
  
  def down
    rename_table  :team_users, :student_teams
  end
end
