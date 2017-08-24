class Seminar < ApplicationRecord
  
  belongs_to  :user
  has_many    :seminar_students, dependent: :destroy
  has_many    :students, through: :seminar_students, :source => :user
  has_many    :objective_seminars, dependent: :destroy
  has_many    :objectives, through: :objective_seminars
  has_many    :consultancies, dependent: :destroy
  
  validates :user_id, presence: true
  validates :name, presence: true, length: { maximum: 40 }
  validates :consultantThreshold, presence: true, numericality: { only_integer: true }
  
  attribute :consultantThreshold, :integer, default: 7
  
    include ModelMethods
  
  # Limited version of semianr's name
  def limitedName
    if name.length > 12
      "#{name[0,10]}..."
    else
      name[0,12]
    end
  end
  
  def shouldShowConsultLink
    students.count > 1 and objectives.count > 0
  end
  
  def objective_is_pretest(obj)
    self.objective_seminars.find_by(:objective => obj).pretest > 0
  end
  
  def all_pretest_objectives(stud)
    self.objectives.select{|x| objective_is_pretest(x) && stud.has_not_scored_100(x) && stud.has_not_tried_twice(x) && stud.check_if_ready(x)}
  end
  
  def scoreTransfer(fromObj, toObj)
    Objective.find(fromObj).objective_students.each do |oldScore|
      newScore = ObjectiveStudent.find_by(:user_id => oldScore.user_id, :objective_id => toObj)
      if newScore == nil
        newScore = ObjectiveStudent.create(:user_id => oldScore.user_id, :objective_id => toObj)
      end
      
      newScore.update(:points => oldScore.points)
    end
  end
end
