class Question < ApplicationRecord
  include ModelMethods
  
  belongs_to :user
  belongs_to :label
  
  has_many :ripostes, dependent: :destroy
  has_many :questions, through: :ripostes
  belongs_to :picture
  
  serialize :correct_answers
  
  validates :prompt, :presence => true
  validates :extent, :presence => true

  
  def shortPrompt
      prompt[0,30]
  end
  
  private
  
 
    
end