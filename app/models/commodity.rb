class Commodity < ApplicationRecord
    
    belongs_to    :school
    belongs_to    :user
    has_many    :commodity_students
    
    mount_uploader :image, ImageUploader
end
