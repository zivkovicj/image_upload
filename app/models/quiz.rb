class Quiz < ApplicationRecord
    has_many :ripostes, dependent: :destroy, foreign_key: :quiz_id
    has_many :questions, through: :ripostes
    
    belongs_to :user
    belongs_to :objective
end
