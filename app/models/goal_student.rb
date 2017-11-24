class GoalStudent < ApplicationRecord
    after_create  :create_checkpoints
    
    belongs_to  :goal
    belongs_to  :user
    belongs_to  :seminar
    has_many    :checkpoints
    
    attr_accessor :goal_id
    
    attribute :approved, :boolean, default: false
    
    def create_checkpoints
       3.times do |n|
           self.checkpoints.create(:number => n + 1)
       end
    end
end
