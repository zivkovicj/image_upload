class SeminarStudent < ApplicationRecord
    belongs_to :student
    belongs_to :seminar
    
    validates :student_id, presence: true
    validates :seminar_id, presence: true
    
    attribute :pref_request, :integer, default: 1
    
    include ModelMethods
end
