class ObjectiveStudent < ApplicationRecord
    belongs_to :user
    belongs_to :objective
    
    before_create  :establish_score_record
    before_save  :take_keys_when_scoring_100
    
    validates :points, numericality: { only_integer: true, :greater_than_or_equal_to => 0 }
    validates :teacher_granted_keys, numericality: { :less_than_or_equal_to => 6, :greater_than_or_equal_to => 0 }
    validates_uniqueness_of :user, :scope => :objective
    
    attribute :points, :integer, default: 0
    attribute :pretest_keys, :integer, default: 0
    attribute :dc_keys, :integer, default: 0
    attribute :teacher_granted_keys, :integer, default: 0
    
    serialize :current_scores
    serialize :score_record
    
    def establish_score_record
        self.current_scores = [nil, nil, nil, nil]
        self.score_record = []
        20.times do |n|
            score_record[n] = [nil, nil, nil, nil]
        end
    end
    
    def update_scores(latest_score, term, origin, override)
        changed = false
        if override || latest_score >= self.points
            self.points = latest_score
            changed = true
        end
        if origin == "pretest" && (self.pretest_score == nil || latest_score >= self.pretest_score)
            self.pretest_score = latest_score
            changed = true
        end
        if override || ((origin == "teacher_granted" || origin == "dc") && (self.current_scores[term] == nil || latest_score >= self.current_scores[term]))
            self.current_scores[term] = latest_score
            changed = true
        end
        self.save if changed
    end
    
    def total_keys
        self.teacher_granted_keys + self.pretest_keys + self.dc_keys 
    end
    
    def update_keys(which_key, new_keys)
        old_keys = self.teacher_granted_keys
        current_keys = old_keys + new_keys.to_i
        self.update(:"#{which_key}_keys" => current_keys, :pretest_keys => 0)
    end
    
    def take_keys_when_scoring_100
        if self.points == 10
            self.teacher_granted_keys = 0
            self.dc_keys = 0
            self.pretest_keys = 0
        end
    end
end
