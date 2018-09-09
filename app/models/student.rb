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

    def bucks_current(category, target)
        self.bucks_earned(category, target) - self.bucks_spent(category, target)
    end
    
    def bucks_earned(category, target)
        self.currencies.where(category => target).sum(:value)
    end
    
    def bucks_spent(category, target)
        self.commodity_students.where(category => target).sum(:price_paid)
    end
    
    def com_quant(commode)
        self.commodity_students.where(:commodity => commode).sum(:quantity)
    end
    
    def com_quant_delivered(commode)
        self.commodity_students.where(:commodity => commode, :delivered => true).count 
    end
    
    def quiz_stars_this_term(seminar)
        objective_students
            .where(:objective => seminar.objectives).to_a
            .sum{ |x| x.points_this_term.to_i }
    end
    
    def stars_used_toward_grade_this_term(seminar, term)
        self.seminar_students.find_by(:seminar => seminar).stars_used_toward_grade[term]
    end
    
    def quiz_stars_all_time(seminar)
        objective_students.where(:objective => seminar.objectives).map(&:points_all_time).inject{|a,b| a.to_i + b.to_i}
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
        objective_students.find_by(:objective => objective).points_all_time.to_i
    end
    
    def learn_request_in(seminar)
        self.seminar_students.find_by(:seminar => seminar).learn_request
    end
    
    def teach_request_in(seminar)
        self.seminar_students.find_by(:seminar => seminar).teach_request
    end
    
    def teach_options(seminar, assign_list)
        objective_students.where(:objective_id => seminar.objs_above_zero_priority)
            .where(:points_all_time => seminar.consultantThreshold..9)
            .select{|x| x.total_keys == 0}
            .take(10)
            .map(&:objective)
            .sort_by{|x| [-x.priority_in(seminar), -x.students_who_requested(seminar)] }
    end
    
    def learn_options(seminar, assign_list)
        assign_list.select{|x| self.objective_students.find_by(:objective => x).obj_ready_and_willing?(seminar.consultantThreshold)}.take(10) 
    end
    
    def present_in(seminar)
        self.seminar_students.find_by(:seminar => seminar).present
    end
    
    def advance_to_next_school_year
        self.update(:school_year => self.school_year + 1)
    end
    
    def student_has_keys(obj)
        objective_students.find_by(:objective => obj).total_keys
    end
end
