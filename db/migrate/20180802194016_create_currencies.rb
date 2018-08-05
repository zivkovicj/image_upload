class CreateCurrencies < ActiveRecord::Migration[5.0]
  def change
    create_table :currencies do |t|
      t.references  :user, index: true
      t.references  :seminar, index: true
      t.references  :school, index: true
      t.references  :giver, index: true, foreign_key: {to_table: :users}
      t.integer     :value
      t.text        :comment
      
      t.timestamps
    end
  end
end
