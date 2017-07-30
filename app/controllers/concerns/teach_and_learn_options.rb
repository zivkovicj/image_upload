module TeachAndLearnOptions
    extend ActiveSupport::Concern
    
    # Creates the list of objectives the student is qualified to be a consultant for
    def teachOptions(student, rankAssignsByNeed, cThresh, listLimit)
        teachOptArray = []
        [[cThresh,99],[100,100]].each do |n|
            rankAssignsByNeed.each do |objective|
                this_score = student.objective_students.find_by(:objective_id => objective.id)
                if this_score
                    thisPoints = this_score.points
                    teachOptArray.push(objective) if (thisPoints >= n[0] && thisPoints <= n[1])
                end
            end
            break if teachOptArray.length > listLimit
        end
        return teachOptArray
    end
    
    # Creates the list of objectives the student is ready to learn
    def learnOptions(student, rankAssignsByNeed, listLimit)
        learnOptArray = []
        [[0,74],[75,90]].each do |n|
            rankAssignsByNeed.each do |objective|
                if student.checkIfReady(objective)
                    thisPoints = student.objective_students.find_by(:objective_id => objective.id).points
                    learnOptArray.push(objective) if (thisPoints >= n[0] && thisPoints <= n[1])
                end
                break if learnOptArray.length >= listLimit
            end
        end
        return learnOptArray
    end
    
end