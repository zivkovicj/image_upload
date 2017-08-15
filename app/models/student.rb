class Student < User
    
    has_many   :seminar_students, dependent: :destroy, foreign_key: :user_id
    has_many   :seminars, through: :seminar_students
    has_many   :objective_students, dependent: :destroy, foreign_key: :user_id
    has_many   :consulted_teams, :class_name => "Team", foreign_key: "consultant_id"
    #has_many   :quizzes
    has_many   :student_teams, foreign_key: :user_id
    has_many   :teams, through: :student_teams
    
    validates_uniqueness_of :username, unless: Proc.new { |a| a.username.blank? }
    has_secure_password :validations => false, :allow_nil => true
    
   
    # Add the total points for this student
    def total_points()
        objective_students.sum(:points)
    end
    
    # Returns first name with limit plus last initial
    def firstPlusInit
        "#{first_name[0,15].split.map(&:capitalize).join(' ')} #{last_name[0,1].split.map(&:capitalize).join(' ')}" 
    end
    
    def fullName
        "#{first_name[0,20].split.map(&:capitalize).join(' ')} #{last_name[0,20].split.map(&:capitalize).join(' ')}"
    end
    
    def last_name_first
        "#{last_name[0,20].split.map(&:capitalize).join(' ')}, #{first_name[0,20].split.map(&:capitalize).join(' ')}"
    end
    
    # Returns adjusted Consultant Points based on pref_request
    def appliedConsultPoints(seminar)
        #prePoints = 
    end
    
    # Checks whether a student has met all pre-requisites for an objective
    def check_if_ready(objective)
        objective.preassigns.each do |preassign|
            droog = objective_students.find_by(objective_id: preassign.id)
            if droog and droog.points < 70
              return false
            end
        end
        return true
    end
    
    
    
    

end
