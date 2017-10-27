module TeachAndLearnOptions
    extend ActiveSupport::Concern
    
    # Creates the list of objectives the student is qualified to be a consultant for
    def teach_options(student, seminar, list_limit)
        teach_opt_array = []
        [[seminar.consultantThreshold,99],[100,100]].each do |n|
            @seminar.objective_seminars.each do |os|
                obj = os.objective
                this_score = @student_scores.find_by(:objective => obj)
                if this_score
                    this_points = this_score.points
                    teach_opt_array.push(obj) if (this_points >= n[0] && this_points <= n[1])
                end
                break if teach_opt_array.length > list_limit
            end
            break if teach_opt_array.length > list_limit
        end
        return teach_opt_array
    end
    
    # Creates the list of objectives the student is ready to learn
    def learn_options(student, seminar, list_limit)
        learn_opt_array = []
        [[0,74],[75,90]].each do |n|
            @oss.each do |os|
                obj = os.objective
                if student.check_if_ready(obj)
                    this_points = @student_scores.find_by(:objective => obj).points
                    learn_opt_array.push(obj) if (this_points >= n[0] && this_points <= n[1])
                end
                break if learn_opt_array.length >= list_limit
            end
            break if learn_opt_array.length >= list_limit
        end
        return learn_opt_array
    end
    
end