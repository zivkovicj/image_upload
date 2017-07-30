class CreateStudents < ActiveRecord::Migration[5.0]
  def change
    create_table :students do |t|
      t.string   "first_name"
      t.string   "last_name"
      t.string   "email"
      t.string   "password_digest"
      t.integer  "student_number"
      t.string   "username"
      t.string   "role"
      t.datetime   "last_login"
      t.integer    "current_class"
      
      t.timestamps
    end
  end
end
