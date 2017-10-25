module AddStudentStuff
    extend ActiveSupport::Concern
    
    def addToSeatingChart(seminar, student)
        #seminar.seating.push(student.id)
        #seminar.save
    end
    
    def scoresForNewStudent(seminar, student)
        seminar.objectives.each do |objective|
            objective.objective_students.create!(:user => student, :points => 0) if objective.objective_students.find_by(:user => student) == nil
        end
    end
    
    def calculate_percentile(array, percentile)
        array.sort[(percentile * array.length).ceil - 1]
    end
    
        
end