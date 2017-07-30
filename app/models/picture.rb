class Picture < ApplicationRecord
  has_many   :label_pictures
  has_many   :labels, through: :label_pictures
  has_many :questions
  
  validates_presence_of :image
  mount_uploader :image, ImageUploader
end
