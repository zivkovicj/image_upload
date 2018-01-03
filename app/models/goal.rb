class Goal < ApplicationRecord
    serialize :actions
    
    belongs_to :user
    
    attribute   :extent, :string, default: "private"
    
    validates :name, length: {maximum: 50}, presence: true
    validate   :four_actions
    
    private
    
        def four_actions
            if self.actions == nil
                self.errors.add(:actions, "cannot be blank") 
            else
                these_actions = self.actions
                self.errors.add(:actions, "cannot be blank") if these_actions.length != 4
                self.errors.add(:actions, "checkpoint 1 needs at least one action") if these_actions[0][0].blank?
                self.errors.add(:actions, "checkpoint 2 needs at least one action") if these_actions[1][0].blank?
                self.errors.add(:actions, "checkpoint 3 needs at least one action") if these_actions[2][0].blank?
                self.errors.add(:actions, "checkpoint 4 needs at least one action") if these_actions[3][0].blank?
            end
        end

end
