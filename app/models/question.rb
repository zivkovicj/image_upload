class Question < ApplicationRecord
  belongs_to :user
  belongs_to :label
  belongs_to :picture
end
