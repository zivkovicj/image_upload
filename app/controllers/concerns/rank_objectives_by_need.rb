module RankObjectivesByNeed
    extend ActiveSupport::Concern


    # Rank objectives by their priority and need
    def rank_objectives_by_need(seminar)
        assign_array = []
        [3,2,1].each do |n|
            pre_array = []
            seminar.objective_seminars.each do |os|
                pre_array.push(os.objective) if os.priority == n
            end
            little_array = pre_array.sort_by{|x| [x.students_who_requested(seminar)]}.reverse!
            little_array.each do |objective|
                assign_array.push(objective) 
            end
        end
        return assign_array
    end
    
    
end