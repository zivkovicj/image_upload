class AddSalableToCommodity < ActiveRecord::Migration[5.0]
  def change
    add_column  :commodities, :salable, :boolean
    add_column  :commodities, :usable, :boolean
  end
end
