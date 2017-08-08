module RankObjectivesByNeed
    extend ActiveSupport::Concern


    # Rank objectives by their priority and need
    def rankAssignsByNeed(seminar)
        assignArray = []
        [3,2,1].each do |n|
            preArray = []
            seminar.objective_seminars.each do |os|
                preArray.push(os.objective) if os.priority == n
            end
            littleArray = preArray.sort_by{|x| [x.students_in_need(seminar)]}
            littleArray.reverse!
            littleArray.each do |objective|
                assignArray.push(objective) 
            end
        end
        return assignArray
    end
    
    
end