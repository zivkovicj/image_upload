class ObjectiveStudent < ApplicationRecord
    belongs_to :student
    belongs_to :objective
    
    validates :points, numericality: { only_integer: true, :greater_than_or_equal_to => 0 }
    
    attribute :points, :integer, default: 0
end
