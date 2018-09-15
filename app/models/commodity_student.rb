class CommodityStudent < ApplicationRecord
    belongs_to  :commodity
    belongs_to  :user
    belongs_to  :seminar
    belongs_to  :school
    
    attribute :quantity, :integer, default: 0
    attribute :avg_price_paid, :integer, default: 0
    attribute :delivered, :boolean, default: false
    
    def self.needs_delivered
        where(:delivered => false)
    end
end
