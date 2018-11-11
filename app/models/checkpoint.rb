class Checkpoint < ApplicationRecord
    belongs_to  :goal_student
    
    
    def statement
        if self.action
            replacer = self.goal_student.target.to_s
            replacer.present? ? self.action.gsub("(?)", replacer) : self.action
        end
    end
    
    def grade_percentage
        this_achieve = self.achievement
        this_target = self.goal_student.target
        if !self.action&.include?("(?)")
            return this_achieve
        elsif this_achieve == 0
            return 0
        elsif this_achieve && this_target
            max_achieve = [this_achieve, this_target].min
            temp_percent = (100 * max_achieve / this_target).round
            temp_percent = temp_percent - 10 if (this_achieve < this_target)
            temp_percent = [temp_percent, 10].max
            return temp_percent
        else
            return ""
        end
    end
end
