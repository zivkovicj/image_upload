class AddOwnerToSeminar < ActiveRecord::Migration[5.0]
  def change
    add_reference  :seminars, :owner, :foreign_key => true
  end
end
