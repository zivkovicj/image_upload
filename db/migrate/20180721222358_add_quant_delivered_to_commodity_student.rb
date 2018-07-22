class AddQuantDeliveredToCommodityStudent < ActiveRecord::Migration[5.0]
  def change
    add_column  :commodity_students, :quant_delivered, :integer
    add_column  :commodities, :deliverable, :boolean
  end
end
