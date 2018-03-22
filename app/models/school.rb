class School < ApplicationRecord
    belongs_to   :mentor,  :class_name => "Teacher"
    has_many  :teachers
    has_many  :students
    
    include ModelMethods
    
    validates :name, presence: true
    validates :city, presence: true
    validates :state, presence: true
    
    def verified_teachers
        self.teachers.where(:verified => 1) 
    end
    
    def check_for_unverified_teachers
        self.teachers.where(:verified => 0)
    end
end
