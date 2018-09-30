class ObjectiveStudent < ApplicationRecord
    belongs_to :user
    belongs_to :objective
    
    validates :teacher_granted_keys, numericality: { :less_than_or_equal_to => 6, :greater_than_or_equal_to => 0 }
    validates_uniqueness_of :user, :scope => :objective
    
    attribute :pretest_keys, :integer, default: 0
    attribute :dc_keys, :integer, default: 0
    attribute :teacher_granted_keys, :integer, default: 0
    
    # Checks whether a student has met all pre-requisites for an objective
    def obj_ready?
        user.objective_students.where(:objective => objective.preassigns).all? {|obj_stud| obj_stud.points_all_time.to_i >= 6 }
    end
    
    def obj_willing?(max)
        points_all_time.to_i < max
    end
    
    def obj_ready_and_willing?(max)
        obj_ready? && obj_willing?(max)
    end
    
    def passed
        self.points_all_time.to_i >= 6
    end
    
    def passed_with_100
        self.points_all_time.to_i == 10
    end
    
    def set_points(origin, this_score)
        new_score_all_time = Quiz.where(:user_id => user_id, :objective_id => objective_id).maximum(:total_score)
        self.points_all_time = new_score_all_time
        
        if origin == "pretest"
            self.pretest_score = this_score if this_score > self.pretest_score.to_i
        elsif origin == "manual"
            self.points_this_term = this_score
        else
            self.points_this_term = [points_this_term.to_i, this_score].max
        end
        
        self.save
        self.take_all_keys if points_all_time == 10
    end
    
    def take_all_keys
        self.update(:teacher_granted_keys => 0, :dc_keys => 0, :pretest_keys => 0)
    end
    
    def total_keys
        self.teacher_granted_keys + self.pretest_keys + self.dc_keys 
    end
    
    def update_keys(which_key, new_keys)
        old_keys = self.read_attribute(:"#{which_key}_keys")
        current_keys = old_keys + new_keys.to_i
        self.update(:"#{which_key}_keys" => current_keys, :pretest_keys => 0)
    end
end
