class Quiz < ApplicationRecord
    has_many :ripostes, dependent: :destroy, foreign_key: :quiz_id
    belongs_to :user
    belongs_to :objective
end
