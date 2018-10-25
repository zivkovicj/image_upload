class AddTermToSeminar < ActiveRecord::Migration[5.0]
  def change
    add_column  :seminars, :term, :integer
  end
end
