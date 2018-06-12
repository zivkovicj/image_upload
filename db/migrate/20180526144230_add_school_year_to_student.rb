class AddSchoolYearToStudent < ActiveRecord::Migration[5.0]
  def change
    add_column  :users, :school_year, :integer
    add_column  :seminars, :school_year, :integer
  end
end
