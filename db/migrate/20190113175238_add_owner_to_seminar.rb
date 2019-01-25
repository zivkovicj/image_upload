class AddOwnerToSeminar < ActiveRecord::Migration[5.0]
  def change
    add_reference  :seminars, :owner, :foreign_key => {to_table: :users}
  end
end
