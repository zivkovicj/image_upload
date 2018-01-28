class GoalStudent < ApplicationRecord
    after_create  :create_checkpoints
    
    belongs_to  :goal
    belongs_to  :user
    belongs_to  :seminar
    has_many    :checkpoints
    
    attr_accessor :goal_id
    
    attribute :approved, :boolean, default: false
    
    # Probably won't need this method anymore
    #def this_gs_term
        #self.user.goal_students.where(:seminar => self.seminar).find_index(self) 
    #end
    
    def statement_with_target
        self.goal.statement_stem.gsub("(?)", self.target.to_s) if self.goal
    end
    
    def all_actions_with_targets
        actions_array = [[],[],[],[]]
        these_actions = self.goal.actions
        these_actions.each_with_index do |action_level, index|
            action_level.each do |this_action|
                actions_array[index].push(this_action.gsub("(?)", self.target.to_s))
            end
        end
        return actions_array
    end
    
    def create_checkpoints
        4.times do |n|
            self.checkpoints.create(:sequence => n)
        end
    end
    
    def gs_update_stuff
        this_goal = Goal.find(self.goal_id)
        self.goal = this_goal
        self.checkpoints.find_by(:sequence => 0).update(:action => this_goal.actions[0][0])
        self.checkpoints.find_by(:sequence => 1).update(:action => this_goal.actions[1][0])
        self.checkpoints.find_by(:sequence => 2).update(:action => this_goal.actions[2][0])
        self.checkpoints.find_by(:sequence => 3).update(:action => this_goal.actions[3][0])
        self.save
    end

end
