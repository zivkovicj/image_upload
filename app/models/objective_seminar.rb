class ObjectiveSeminar < ApplicationRecord
    belongs_to :seminar
    belongs_to :objective
    
    attribute :priority, :integer, default: 2
    attribute :pretest, :integer, default: 0
    
    before_create :createScores, :addPreReqs
    
    private
        def createScores
            seminar.students.each do |student|
                if student.objective_students.find_by(:objective_id => objective.id) == nil
                    student.objective_students.create(:objective_id => objective.id, :points => 0)
                end
            end
        end
        
        def addPreReqs
            objective.preassigns.each do |preassign|
                if seminar.objectives.include?(preassign) == false
                    ObjectiveSeminar.create(:objective_id => preassign.id, :seminar_id => seminar.id)
                    seminar.students.each do |student|
                        if student.objective_students.find_by(:objective_id => preassign.id) == nil
                            ObjectiveStudent.create(:student_id => student.id, :objective_id => preassign.id)
                        end
                    end
                end
            end
        end
end
