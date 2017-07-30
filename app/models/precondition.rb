class Precondition < ApplicationRecord
    belongs_to :mainassign, class_name: "Objective"
    belongs_to :preassign, class_name: "Objective"
    
    before_create :addSubPreconditions
    
    def addSubPreconditions
        preassign.preassigns.each do |subpreassign|
            if mainassign.preassigns.include?(subpreassign) == false
                Precondition.create(:mainassign_id => mainassign.id, :preassign_id => subpreassign.id)
            end
        end
        
        mainassign.mainassigns.each do |supermainassign|
            if supermainassign.preassigns.include?(preassign) == false
                Precondition.create(:mainassign_id => supermainassign.id, :preassign_id => preassign.id)
            end
        end
        
    end
end
