class SeminarTeacher < ApplicationRecord
    belongs_to :user
    belongs_to :seminar

    validates :user_id, presence: true
    validates :seminar_id, presence: true
    
    attribute :can_edit, :boolean, default: false
    attribute :accepted, :boolean, default: false
    
    include ModelMethods
end