class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.integer :current_class
      t.string :password_digest
      t.string :remember_digest
      t.string :role
      t.string :activation_digest
      t.boolean :activated
      t.datetime :activated_at
      t.string :reset_digest
      t.datetime :reset_sent_at
      t.string :title
      t.datetime :last_login
      t.string :username

      t.timestamps
    end
  end
end
