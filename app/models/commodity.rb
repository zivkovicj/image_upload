class Commodity < ApplicationRecord
    
    belongs_to    :school
    belongs_to    :teacher,  :class_name => "User"
    has_many      :commodity_students, dependent: :destroy
    has_many      :students, through: :commodity_students, :source => :user
    
    mount_uploader :image, ImageUploader
end
