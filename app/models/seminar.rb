class Seminar < ApplicationRecord
  
  belongs_to  :user
  has_many    :seminar_students, dependent: :destroy
  has_many    :students, through: :seminar_students, :source => :user
  has_many    :objective_seminars, dependent: :destroy
  has_many    :objectives, through: :objective_seminars
  has_many    :consultancies, dependent: :destroy
  has_many    :teams, through: :consultancies
  has_many    :goal_students
  
  validates :user_id, presence: true
  validates :name, presence: true, length: { maximum: 40 }
  validates :consultantThreshold, presence: true, numericality: { only_integer: true }
  
  attribute :consultantThreshold, :integer, default: 7
  attribute :term, :integer, default: 0
  attribute :which_checkpoint, :integer, default: 0
  
  serialize :checkpoint_due_dates
  
  due_date_array = 
    [["06/05/2019","06/05/2019","06/05/2019","06/05/2019"],
     ["06/05/2019","06/05/2019","06/05/2019","06/05/2019"],
     ["06/05/2019","06/05/2019","06/05/2019","06/05/2019"],
     ["06/05/2019","06/05/2019","06/05/2019","06/05/2019"]]
  attribute :checkpoint_due_dates, :text, default: due_date_array
  
  include ModelMethods
  
  def shouldShowConsultLink
    students.count > 1 and objectives.count > 0
  end
  
  def objective_is_pretest(obj)
    self.objective_seminars.find_by(:objective => obj).pretest > 0
  end
  
  def all_pretest_objectives(stud)
    self.objectives.select{|x| objective_is_pretest(x) && stud.has_not_scored_100(x) && stud.has_not_tried_twice(x) && stud.check_if_ready(x) && !stud.one_unfinished(x)}
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
  
  def rank_objectives_by_need
    objectives.select{|z| z.priority_in(self) > 0}.sort_by{|x| [-x.priority_in(self), -x.students_who_requested(self)] }
  end
  
  def set_random_goals
    self.students.each do |stud|
      stud.goal_students.each do |gs|
        if rand(2) == 1
          gs.update(:goal => Goal.all[rand(Goal.count)])
        end
      end
    end
  end
end
