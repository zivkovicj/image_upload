class Consultancy < ApplicationRecord
    belongs_to :seminar
    has_many :teams, dependent: :destroy
    has_many :users, through: :teams
    
    attribute   :duration, :string, :default => "preview"
    
    def display_date
       updated_at.strftime("%B %d, %Y") 
    end
    
    def all_consultants
        teams.where.not(:consultant => nil).map(&:consultant) 
    end
end
