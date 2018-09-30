class RemoveBucksOwned < ActiveRecord::Migration[5.0]
  def change
    remove_column   :commodity_students, :quant_delivered, :integer
    rename_column   :commodity_students, :avg_price_paid, :price_paid
    add_column      :commodity_students, :delivered, :boolean
    add_reference   :commodity_students, :seminar, index: true
    add_reference   :commodity_students, :school, index: true
  end
end
