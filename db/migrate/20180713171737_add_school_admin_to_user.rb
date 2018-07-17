class AddSchoolAdminToUser < ActiveRecord::Migration[5.0]
  def change
    add_column  :users, :school_admin, :integer
    remove_column  :schools, :mentor_id
  end
end
