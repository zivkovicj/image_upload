class CreateSeminarTeachers < ActiveRecord::Migration[5.0]
  def change
    create_table :seminar_teachers do |t|
      t.references  :seminar, foreign_key: true
      t.references  :user, foreign_key: true
      t.boolean     :can_edit
      t.boolean     :accepted
    end
    
    add_index :seminar_teachers, [:seminar_id, :user_id]
  end
end
