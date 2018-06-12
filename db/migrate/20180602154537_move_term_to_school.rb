class MoveTermToSchool < ActiveRecord::Migration[5.0]
  def change
    remove_column    :seminars, :term
    add_column       :schools, :term, :integer
  end
end
