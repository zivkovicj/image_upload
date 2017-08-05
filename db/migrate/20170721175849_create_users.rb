class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string  :type
      t.string :title
      t.string  :first_name
      t.string  :last_name
      t.string  :username
      t.string  :password_digest
      t.string  :email
      t.integer  :user_number
      t.integer  :current_class
      t.string  :remember_digest
      t.string  :activation_digest
      t.boolean  :activated
      t.datetime :activated_at
      t.string  :reset_digest
      t.datetime  :reset_sent_at
      t.datetime  :last_login

      t.timestamps
    end
  end
end
