module NeedDelivered
    extend ActiveSupport::Concern

    def commodities_needing_delivered
        CommodityStudent.where(:commodity => self.commodities.deliverable, :user => self.students, :delivered => false)
    end
    
end