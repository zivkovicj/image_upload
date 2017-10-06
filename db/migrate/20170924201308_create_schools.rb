class CreateSchools < ActiveRecord::Migration[5.0]
  def change
    create_table :schools do |t|
      t.string  :name
      t.string  :city
      t.string  :state
      t.references  :mentor, references: :user, foreign_key: true
      t.timestamps
    end
    
    add_reference  :users, :school, foreign_key: true
    add_column    :users, :verified, :integer
    add_reference  :users, :sponsor, references: :user, foreign_key: true
  end
end
