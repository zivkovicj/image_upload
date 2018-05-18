class ObjectiveStudent < ApplicationRecord
    belongs_to :user
    belongs_to :objective
    
    before_save  :take_keys_when_scoring_100
    
    validates :points, numericality: { only_integer: true, :greater_than_or_equal_to => 0 }
    validates :teacher_granted_keys, numericality: { :less_than_or_equal_to => 6, :greater_than_or_equal_to => 0 }
    validates_uniqueness_of :user, :scope => :objective
    
    attribute :points, :integer, default: 0
    attribute :pretest_keys, :integer, default: 0
    attribute :dc_keys, :integer, default: 0
    attribute :teacher_granted_keys, :integer, default: 0
    
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
