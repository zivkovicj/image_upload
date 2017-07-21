class Picture < ApplicationRecord
  belongs_to :label
  has_many :questions
  
  validates_presence_of :image
  mount_uploader :image, ImageUploader
end
