class CreateCommodities < ActiveRecord::Migration[5.0]
  def change
    create_table :commodities do |t|
      t.string  :name
      t.string  :image
      t.references  :school, :foreign_key => true
      t.references  :user,   :foreign_key => true
      t.integer  :production_rate
      t.integer :current_price
      t.integer  :production_day
      t.integer  :quantity
      t.datetime  :date_last_produced
      t.timestamps
    end
  end
end
