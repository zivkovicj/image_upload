class Label < ApplicationRecord
  belongs_to :user
  has_many :questions
  has_many  :label_pictures
  has_many  :pictures, through: :label_pictures
  has_many :label_objectives, dependent: :destroy,
                        foreign_key: :label_id
  has_many :objectives, through: :label_objectives
  
  validates :name, :presence => true
  
  include ModelMethods

end
