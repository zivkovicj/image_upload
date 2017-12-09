class Checkpoint < ApplicationRecord
    belongs_to  :goal_student
    
    
    def statement
        if self.action
            replacer = self.goal_student.target.to_s
            replacer.present? ? self.action.gsub("(?)", replacer) : self.action
        end
    end
end
