class Consultancy < ApplicationRecord
    belongs_to :seminar
    has_many :teams, dependent: :destroy
    has_many :users, through: :teams
    
    def display_date
       updated_at.strftime("%B %d, %Y") 
    end
end
