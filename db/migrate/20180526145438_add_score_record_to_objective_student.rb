class AddScoreRecordToObjectiveStudent < ActiveRecord::Migration[5.0]
  def change
    add_column  :objective_students, :current_scores, :text
    add_column  :objective_students, :score_record, :text
    add_column  :objective_students, :pretest_score, :integer
    add_column  :objective_students, :teacher_manual_score, :integer
  end
end
