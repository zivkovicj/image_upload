class Objective < ApplicationRecord
    has_many    :objective_students, dependent: :destroy
    
    has_many    :objective_seminars, dependent: :destroy
    has_many    :seminars, through: :objective_seminars
    
    has_many    :preconditions, class_name: "Precondition",
                                foreign_key: "mainassign_id",
                                dependent: :destroy
    has_many    :mainconditions, class_name: "Precondition",
                                foreign_key: "preassign_id",
                                dependent: :destroy
    has_many    :preassigns, through: :preconditions, as: :mainassign, source: :preassign
    has_many    :mainassigns, through: :mainconditions, as: :preassign, source: :mainassign
    
    has_many    :label_objectives, dependent: :destroy, foreign_key: :objective_id
    has_many    :labels, through: :label_objectives
    has_many    :questions, through: :labels
    
    has_many    :teams, dependent: :destroy
    
    belongs_to  :user
    
    validates :name, presence: true, length: { maximum: 40 }
    
    include ModelMethods
    
    before_save   :downcase_stuff
    
    def studentsInNeed(seminar)
        studsInNeed = 0
        seminar.students.each do |student|
            boog = student.objective_students.find_by(objective_id: id)
            if boog and boog.points and boog.points < 75 and student.checkIfReady(self)
                studsInNeed += 1
            end
        end
        return studsInNeed
    end
    
    def fullName
        name[0,30] 
    end
    
    private
        def downcase_stuff
            self.name.downcase!
        end
        
        

end
