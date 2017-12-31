class GoalStudent < ApplicationRecord
    after_create  :create_checkpoints
    
    belongs_to  :goal
    belongs_to  :user
    belongs_to  :seminar
    has_many    :checkpoints
    
    attr_accessor :goal_id
    
    attribute :approved, :boolean, default: false
    
    def this_gs_term
        self.user.goal_students.where(:seminar => self.seminar).find_index(self) 
    end
    
    def statement_with_target
        self.goal.statement_stem.gsub("(?)", self.target.to_s) if self.goal
    end
    
    def create_checkpoints
        4.times do |n|
            self.checkpoints.create
        end
    end
    
    def gs_update_stuff
        this_goal = Goal.find(self.goal_id)
        self.goal = this_goal
        self.checkpoints[0].update(:action => this_goal.actions[0][0])
        self.checkpoints[1].update(:action => this_goal.actions[1][0])
        self.checkpoints[2].update(:action => this_goal.actions[2][0])
        self.checkpoints[3].update(:action => this_goal.actions[3][0])
        self.save
    end

end
