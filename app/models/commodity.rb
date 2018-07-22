class Commodity < ApplicationRecord
    
    belongs_to    :school
    belongs_to      :user
    has_many      :commodity_students, dependent: :destroy
    has_many      :students, through: :commodity_students, :source => :user
    
    mount_uploader :image, ImageUploader
    
    banned_words = %w(Star star STAR Stars stars STARS Gem gem GEM Gems gems GEMS)
    validates  :name, :presence => true, :exclusion => { in: banned_words, message: "%{value} is reserved." }, :on => :create
end
