class Question < ApplicationRecord
  include ModelMethods
  
  belongs_to :user
  belongs_to :label
  
  has_many :ripostes, dependent: :destroy
  belongs_to :picture
  
  serialize :correct_answers
  
  attribute  :extent, :string, default: "private"
  
  validates :prompt, :presence => true
  validates :extent, :presence => true
  
  def short_prompt
      prompt[0,30]
  end
  
  private
  
    
end
