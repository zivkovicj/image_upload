module AddStudentStuff
    extend ActiveSupport::Concern
    
    def addToSeatingChart(seminar, student)
        #seminar.seating.push(student.id)
        #seminar.save
    end
    
    def scores_for_new_student(seminar, student)
        seminar.objectives.each do |objective|
            objective.objective_students.create!(:user => student, :points => 0) if objective.objective_students.find_by(:user => student) == nil
        end
    end
    
    def pretest_keys_for_new_student(seminar, student)
        seminar.objective_seminars.where(:pretest => 1).each do |os|
            this_obj_stud = student.objective_students.find_by(:objective => os.objective)
            this_obj_stud.update(:pretest_keys => 2) unless this_obj_stud.points == 10
        end
    end
    
    def goals_for_new_student(seminar, student)
        4.times do |n|
            student.goal_students.create(:seminar_id => seminar.id, :term => n)
        end
    end
    
    def calculate_percentile(array, percentile)
        array.sort[(percentile * array.length).ceil - 1]
    end
    
        
end