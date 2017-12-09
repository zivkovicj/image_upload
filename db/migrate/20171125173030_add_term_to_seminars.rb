class AddTermToSeminars < ActiveRecord::Migration[5.0]
  def change
    add_column  :seminars, :term, :integer
    add_column  :seminars, :which_checkpoint, :integer
  end
end
