class Currency < ApplicationRecord
    belongs_to      :user
    belongs_to      :seminar
    belongs_to      :school
    belongs_to      :giver, :class_name => "User"
end
