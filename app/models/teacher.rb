class Teacher < User
    
    before_destroy  :destroy_associated_records
    
    has_many    :own_seminars, :class_name => "Seminar", foreign_key: 'user_id'
    has_many    :students, through: :own_seminars

    validates  :password, presence: true,
                    length: {minimum: 6},
                    allow_nil: true
    has_secure_password
    
    private
    
        def destroy_associated_records
            Objective.where(:user => self).each do |objective|
                objective.destroy
            end
            self.own_seminars.each do |seminar|
                seminar.destroy
            end
        end

end
