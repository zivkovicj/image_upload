class Quiz < ApplicationRecord
    has_many :ripostes, dependent: :destroy, foreign_key: :quiz_id
    has_many :questions, through: :ripostes
    belongs_to  :seminar
    
    after_save    :set_points_for_obj_stud
    
    belongs_to :user
    belongs_to :objective
    
    def added_stars
        [self.total_score - self.old_stars, 0].max
    end
    
    private
        def set_points_for_obj_stud
            if total_score.present?
                this_obj_stud = ObjectiveStudent.find_by(:user_id => user_id, :objective_id => objective_id)
                this_obj_stud.set_points(origin, total_score)
            end
        end
end
