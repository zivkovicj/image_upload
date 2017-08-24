class SeminarStudent < ApplicationRecord
    belongs_to :user
    belongs_to :seminar
    
    validates :user_id, presence: true
    validates :seminar_id, presence: true
    
    attribute :pref_request, :integer, default: 1
    attribute :present, :boolean, default: true
    
    include ModelMethods
    
end
