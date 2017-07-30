class Seminar < ApplicationRecord
  belongs_to  :teacher, class_name: "User"
  
  has_many    :seminar_students, dependent: :destroy
  has_many    :students, through: :seminar_students
  
  has_many    :objective_seminars, dependent: :destroy
  has_many    :objectives, through: :objective_seminars
  
  has_many    :consultancies, dependent: :destroy
  
  serialize :seating
  serialize :needSeat
  
  validates :teacher_id, presence: true
  validates :name, presence: true, length: { maximum: 40 }
  validates :consultantThreshold, presence: true, numericality: { only_integer: true }
  
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
  
  def scoreTransfer(fromObj, toObj)
    Objective.find(fromObj).objective_students.each do |oldScore|
      newScore = ObjectiveStudent.find_by(:student_id => oldScore.student_id, :objective_id => toObj)
      if newScore == nil
        newScore = ObjectiveStudent.create(:student_id => oldScore.student_id, :objective_id => toObj)
      end
      
      newScore.update(:points => oldScore.points)
    end
  end
end
