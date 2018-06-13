class CreateCommodities < ActiveRecord::Migration[5.0]
  def change
    create_table :commodities do |t|
      t.string  :name
      t.string  :city
      t.string  :image
      
      t.timestamps
    end
  end
end
