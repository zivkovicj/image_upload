class CreateCommodityStudents < ActiveRecord::Migration[5.0]
  def change
    create_table :commodity_students do |t|
      t.references  :commodity, foreign_key: true
      t.references  :user, foreign_key: true
      t.integer  :quantity
      t.integer  :avg_price_paid
      t.timestamps
    end
  end
end
