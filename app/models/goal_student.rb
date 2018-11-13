class GoalStudent < ApplicationRecord
    after_create  :create_checkpoints
    
    belongs_to  :goal
    belongs_to  :user
    belongs_to  :seminar
    has_many    :checkpoints
    
    
    attribute :approved, :boolean, default: false
    
    def checkpoints_in_order
        self.checkpoints.order(:sequence) 
    end
    
    def statement_with_target
        self.goal.statement_stem.gsub("(?)", self.target.to_s) if self.goal
    end
    
    def action_with_target(action)
        temp = action.gsub("(?)", self.target.to_s)
        return temp unless temp == nil
    end
    
    def create_checkpoints
        4.times do |n|
            checkpoint_num = n + 1
            self.checkpoints.create(:sequence => checkpoint_num)
        end
    end
    
    def set_checkpoints
        if self.goal_id.present?
            this_goal = Goal.find(self.goal_id)
            self.checkpoints.find_by(:sequence => 1).update(:action => this_goal.actions[1][0])
            self.checkpoints.find_by(:sequence => 2).update(:action => this_goal.actions[2][0])
            self.checkpoints.find_by(:sequence => 3).update(:action => this_goal.actions[3][0])
            self.checkpoints.find_by(:sequence => 4).update(:action => this_goal.actions[4][0])
            self.save
        end
    end
    


end
