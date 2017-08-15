class StudentTeam < ApplicationRecord
    belongs_to  :user
    belongs_to  :team
end
