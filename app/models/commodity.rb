class Commodity < ApplicationRecord
    belongs_to    :school
    belongs_to    :user
    has_many      :commodity_students, dependent: :destroy
    has_many      :students, through: :commodity_students, :source => :user
    
    mount_uploader :image, ImageUploader
    
    attribute   :current_price, :integer, default: 1
    attribute   :quantity, :integer, default: 10
    attribute   :salable, :boolean, default: false
    attribute   :usable, :boolean, default: false
    
    validates       :name, :presence => true
    
    scope :deliverable, -> { where(:deliverable => true) }
    scope :non_deliverable, -> { where(:deliverable => false) }
end
