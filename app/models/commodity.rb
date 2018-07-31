class Commodity < ApplicationRecord
    belongs_to    :school
    belongs_to    :user
    has_many      :commodity_students, dependent: :destroy
    has_many      :students, through: :commodity_students, :source => :user
    
    mount_uploader :image, ImageUploader
    
    attribute       :salable, :boolean, default: false
    
    validates       :name, :presence => true
end
