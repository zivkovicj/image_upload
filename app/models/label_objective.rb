class LabelObjective < ApplicationRecord
    belongs_to :objective
    belongs_to :label
    
    attribute :quantity, :integer, default: 1
    attribute :point_value, :integer, default: 1

end
