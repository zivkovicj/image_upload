
class CreateSeminarStudents < ActiveRecord::Migration[5.0]
  def change
    create_table :seminar_students do |t|
      t.references  :seminar, foreign_key: true
      t.references  :student, references: :user, foreign_key: true
      t.integer  :teach_request
      t.integer  :learn_request
      t.integer  :pref_request
      t.boolean  :present
      t.integer  :consulting_stars
      
      t.timestamps
    end
    
    add_index :seminar_students, [:seminar_id, :student_id]
  end
end
