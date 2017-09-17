class SeminarStudent < ApplicationRecord
    belongs_to :user
    belongs_to :seminar
    
    after_create :ss_benchmark_stars

    validates :user_id, presence: true
    validates :seminar_id, presence: true
    
    attribute :pref_request, :integer, default: 1
    attribute :present, :boolean, default: true
    
    include ModelMethods
    
    def ss_benchmark_stars
        user = self.user
        sem = self.seminar
        self.update(:benchmark => user.total_stars(sem))
    end
end
