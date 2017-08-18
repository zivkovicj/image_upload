class ChangeIntegerLimitInUsers < ActiveRecord::Migration[5.0]
  def up
    change_column :users, :user_number, :integer, limit: 4
  end
  
  def down
    change_column :users, :user_number, :integer, limit: 4
  end
end
