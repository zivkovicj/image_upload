module AddStudentStuff
    extend ActiveSupport::Concern
    
    def addToSeatingChart(seminar, student)
        #seminar.seating.push(student.id)
        #seminar.save
    end
    
    def scoresForNewStudent(seminar, student)
        seminar.objectives.each do |objective|
            objective.objective_students.create!(:student => student, :points => 0)
        end
    end
    
    def calculate_percentile(array, percentile)
        array.sort[(percentile * array.length).ceil - 1]
    end
    
        
end