class Team < ApplicationRecord
    belongs_to :objective
    belongs_to :consultancy
    
    belongs_to  :consultant, class_name: "Student"
    
    has_many   :student_teams
    has_many  :students, through: :student_teams
    
    def has_room
        return false if self.students.count > 3
        @same_topic_teams = consultancy.teams.where(:objective => self.objective)
        @same_topic_teams.each do |team|
            return false if team.students.count < self.students.count 
        end
        return true
    end
end
