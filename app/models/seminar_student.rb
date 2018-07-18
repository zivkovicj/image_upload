class SeminarStudent < ApplicationRecord
    belongs_to :user
    belongs_to :seminar
    
    after_create  :add_student_stuff

    validates :user_id, presence: true
    validates :seminar_id, presence: true
    
    serialize :stars_used_toward_grade
    
    attribute :pref_request, :integer, default: 1
    attribute :present, :boolean, default: true
    attribute :bucks_owned, :integer, default: 0
    attribute :stars_used_toward_grade, :text, default: [0,0,0,0]
    
    include ModelMethods
    
    private
        def add_student_stuff
            new_student_goals
            new_student_scores
            new_student_pretest_keys
        end
        
        def new_student_goals
            4.times do |n|
                user.goal_students.create(:seminar_id => seminar.id, :term => n)
            end
        end
        
        def new_student_pretest_keys
            seminar.objective_seminars.where(:pretest => 1).each do |os|
                this_obj_stud = user.objective_students.find_by(:objective => os.objective)
                this_obj_stud.update(:pretest_keys => 2) unless this_obj_stud.points == 10
            end
        end
    
        def new_student_scores
            seminar.objectives.each do |obj|
                obj.objective_students.create!(:user => user, :points => 0) if obj.objective_students.find_by(:user => user) == nil
            end
        end
end
