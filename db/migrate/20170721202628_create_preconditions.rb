class CreatePreconditions < ActiveRecord::Migration[5.0]
  def change
    create_table :preconditions do |t|
      t.integer :mainassign_id
      t.integer :preassign_id
      t.timestamps
    end
  end
end
