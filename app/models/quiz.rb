class Quiz < ApplicationRecord
    has_many :ripostes, dependent: :destroy, foreign_key: :quiz_id
    has_many :questions, through: :ripostes
    
    belongs_to :user
    belongs_to :objective
    
    def stars_from_score
        (total_score/10.to_f).ceil
    end
    
    def added_stars
        [self.stars_from_score - self.old_stars, 0].max
    end
end
