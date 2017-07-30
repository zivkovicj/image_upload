class Student < ApplicationRecord
    
    include ModelMethods
    
    attr_accessor :remember_token, :reset_token
    before_save   :downcase_stuff
    
    validates :first_name, presence: true, length: { maximum: 50 }
    validates :last_name, presence: true, length: { maximum: 50 }
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :email, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false },
                    unless: Proc.new { |a| a.email.blank?}
    
    has_secure_password :validations => false
    
    include ModelMethods
    
    
    validates_uniqueness_of :username, unless: Proc.new { |a| a.username.blank? }
    
    # Neccessary for finding all classes that a student is enrolled in
    has_many :seminar_students, dependent: :destroy
    has_many :seminars, through: :seminar_students
                        
    has_many :objective_students, dependent: :destroy,
                        foreign_key: :student_id
    
    has_many :consulted_teams, :class_name => "Team", foreign_key: "consultant_id"
    has_many   :student_teams
    has_many   :teams, through: :student_teams
    
    class << self
        # Returns the hash digest of the given string.
        def digest(string)
            cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                          BCrypt::Engine.cost
            BCrypt::Password.create(string, cost: cost)
        end
        
        # Returns a random token
        def new_token
            SecureRandom.urlsafe_base64
        end
    
    end
    
    # Remembers a user in the database for use in persistent sessions.
    def remember
        #self.remember_token = Student.new_token
        #update_attribute(:remember_digest, Student.digest(remember_token))
    end  
    
    # Returns true if the given token matches the digest.
    def authenticated?(remember_token)
        return false if remember_digest.nil?
        BCrypt::Password.new(remember_digest).is_password?(remember_token)
    end
    
    # Returns true if the given user is the current user.
    def current_student?(student)
        student == current_user
    end
    
    # Forgets a user.
    def forget
        #update_attribute(:remember_digest, nil)
    end
    
    # Sets the password reset attributes.
    def create_reset_digest
        self.reset_token = User.new_token
        update_attribute(:reset_digest,  User.digest(reset_token))
        update_attribute(:reset_sent_at, Time.zone.now)
    end

    # Sends password reset email.
    def send_password_reset_email
        UserMailer.password_reset(self).deliver_now
    end
    
    # Add the total points for this student
    def total_points(scores)
        objective_students.where(:student_id => self.id).sum(:points)
    end
    
    # Returns first name with limit plus last initial
    def firstPlusInit
        "#{first_name[0,15].split.map(&:capitalize).join(' ')} #{last_name[0,1].split.map(&:capitalize).join(' ')}" 
    end
    
    def fullName
        "#{first_name[0,20].split.map(&:capitalize).join(' ')} #{last_name[0,20].split.map(&:capitalize).join(' ')}"
    end
    
    def lastNameFirst
        "#{last_name[0,20].split.map(&:capitalize).join(' ')}, #{first_name[0,20].split.map(&:capitalize).join(' ')}"
    end
    
    # Returns adjusted Consultant Points based on pref_request
    def appliedConsultPoints(seminar)
        #prePoints = 
    end
    
    # Checks whether a student has met all pre-requisites for an objective
    def checkIfReady(objective)
        ready = true
        objective.preassigns.each do |preassign|
            droog = objective_students.find_by(objective_id: preassign.id)
            if droog and droog.points < 75
              ready = false
              break
            end
        end
        return ready
    end
    
    private
    
        def downcase_stuff
          self.email.downcase! if self.email
          self.first_name.downcase!
          self.last_name.downcase!
          self.username.downcase! if self.username
        end

end
