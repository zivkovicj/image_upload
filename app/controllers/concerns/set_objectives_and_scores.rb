module SetObjectivesAndScores
    extend ActiveSupport::Concern
    
    def set_objectives_and_scores(need)
        # '@objectiveIds' picks out the scores that belong to this class
        @objectives = @seminar.objectives.order(:name)
        @objectiveIds = @objectives.map(&:id)
        @scores = ObjectiveStudent.where(objective_id: @objectiveIds)

        if need # For Testing
            return @objectives, @objectiveIds, @scores, @consultId
        end
    end
    
end