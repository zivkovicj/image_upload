class Consultancy < ApplicationRecord
    belongs_to :seminar
    has_many :teams, dependent: :destroy
    has_many :users, through: :teams
    

end
