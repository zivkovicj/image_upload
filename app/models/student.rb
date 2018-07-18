class Student < User
    
    has_many    :seminar_students, dependent: :destroy, foreign_key: :user_id
    has_many    :seminars, through: :seminar_students
    has_many    :commodity_students, dependent: :destroy, foreign_key: :user_id
    has_many    :objective_students, dependent: :destroy, foreign_key: :user_id
    has_many    :objectives, through: :objective_students
    has_many    :consulted_teams, :class_name => "Team", foreign_key: "consultant_id"
    belongs_to   :sponsor,  :class_name => "Teacher"
    
    validates_uniqueness_of :username, unless: Proc.new { |a| a.username.blank? }
    has_secure_password :validations => false, :allow_nil => true

    
    def quiz_stars_this_term(seminar, term)
        temp_stars = 0
        self.objective_students.where(:objective => seminar.objectives).each do |obj_stud|
            this_score = obj_stud.current_scores[term]
            temp_stars = temp_stars + this_score if this_score
        end
        return temp_stars
    end
    
    def stars_used_toward_grade_this_term(seminar, term)
        self.seminar_students.find_by(:seminar => seminar).stars_used_toward_grade[term]
    end
    
    def quiz_stars_all_time(seminar)
        objective_students.where(:objective => seminar.objectives).sum(:points)
    end
    
    # Returns first name with limit plus last initial
    def first_plus_init
        "#{first_name[0,15].split.map(&:capitalize).join(' ')} #{last_name[0,1].split.map(&:capitalize).join(' ')}" 
    end
    
    def full_name
        "#{first_name[0,20].split.map(&:capitalize).join(' ')} #{last_name[0,20].split.map(&:capitalize).join(' ')}"
    end
    
    def last_name_first
        "#{last_name[0,20].split.map(&:capitalize).join(' ')}, #{first_name[0,20].split.map(&:capitalize).join(' ')}"
    end
    
    def consultant_days(seminar)
        @ss = self.seminar_students.find_by(:seminar => seminar)
        last_team = seminar.teams.where(:consultant => self).order(:updated_at).last
        last_consult_date = last_team.present? ? last_team.created_at.to_date : @ss.created_at.to_date
        pre_points = (Date.today - last_consult_date).to_i
        if @ss.pref_request == 2
            pre_points += 1
            pre_points *= 1.2
        elsif @ss.pref_request == 0
            pre_points *= 0.8
            pre_points -= 1
        end
        return pre_points
    end
    
    def score_on(objective)
        this_os = self.objective_students.find_by(:objective => objective)
        return this_os ? this_os.points : 0
    end
    
    def learn_request_in(seminar)
        self.seminar_students.find_by(:seminar => seminar).learn_request
    end
    
    def teach_request_in(seminar)
        self.seminar_students.find_by(:seminar => seminar).teach_request
    end
    
    def teach_options(seminar, assign_list)
        assign_list.select{|x| self.score_on(x) >= seminar.consultantThreshold && self.score_on(x) < 100}.take(10) 
    end
    
    def learn_options(seminar, assign_list)
        assign_list.select{|x| self.score_on(x) < seminar.consultantThreshold && self.check_if_ready(x)}.take(10) 
    end
    
    def present_in(seminar)
        self.seminar_students.find_by(:seminar => seminar).present
    end
    
    def advance_to_next_school_year
        self.objective_students.each do |obj_stud|
            obj_stud.score_record[self.school_year] = obj_stud.current_scores
            obj_stud.current_scores = [nil,nil,nil,nil]
            obj_stud.save
        end
        self.update(:school_year => self.school_year + 1)
    end
    
    # Checks whether a student has met all pre-requisites for an objective
    def check_if_ready(objective)
        objective.preassigns.each do |preassign|
            droog = objective_students.find_by(objective_id: preassign.id)
            if droog and droog.points < 7
              return false
            end
        end
        return true
    end
    
    
    
    

end
