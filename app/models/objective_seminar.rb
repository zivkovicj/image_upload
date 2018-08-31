class ObjectiveSeminar < ApplicationRecord
    belongs_to :seminar
    belongs_to :objective
    
    validates_uniqueness_of :seminar_id, :scope => :objective_id
    
    attribute :priority, :integer, default: 2
    attribute :pretest, :integer, default: 0
    
    before_create :createScores, :addPreReqs
    
    def students_in_need
        objective.objective_students.where(:user => seminar.students).select{|x| !x.passed}.count
    end
    
    private
        def createScores
            seminar.students.each do |student|
                student.objective_students.find_or_create_by(:objective_id => objective.id)
            end
        end
        
        def addPreReqs
            objective.preassigns.each do |preassign|
                if seminar.objectives.include?(preassign) == false
                    ObjectiveSeminar.find_or_create_by(:objective_id => preassign.id, :seminar_id => seminar.id)
                    seminar.students.each do |student|
                        ObjectiveStudent.find_or_create_by(:user_id => student.id, :objective_id => preassign.id)
                    end
                end
            end
        end
end
