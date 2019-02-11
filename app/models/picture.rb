class Picture < ApplicationRecord
  belongs_to   :user
  has_many   :label_pictures, dependent: :destroy
  has_many   :labels, through: :label_pictures
  has_many :questions
  
  validates_presence_of :image
  validates_presence_of :user
  validates_presence_of :name
  
  mount_uploader :image, ImageUploader
  
  attribute   :extent, :string, default: "private"
end
