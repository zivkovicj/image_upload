class CommodityStudent < ApplicationRecord
    belongs_to  :commodity
    belongs_to  :user
    
    attribute :quantity, :integer, default: 0
    attribute :avg_price_paid, :integer, default: 0
    attribute :quant_delivered, :integer, default: 0
end
