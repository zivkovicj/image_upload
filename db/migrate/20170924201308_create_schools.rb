class CreateSchools < ActiveRecord::Migration[5.0]
  def change
    create_table :schools do |t|
      t.string  :name
      t.string  :city
      t.string  :state
      t.integer  :mentor_id
      t.timestamps
    end
    
    add_column  :users, :school_id, :integer
    add_column    :users, :verified, :integer
    add_column  :users, :sponsor_id, :integer
  end
end
