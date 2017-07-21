class Label < ApplicationRecord
  belongs_to :user
  
  has_many :questions
  
  has_many :labeljoins, dependent: :destroy,
                        foreign_key: :label_id
  has_many :labels, through: :labeljoins
  
  validates :name, :presence => true
  
  include ModelMethods

end
