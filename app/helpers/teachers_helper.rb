module TeachersHelper
    
    def admin_rank_compared(acting_faculty, target_faculty, level)
        acting_faculty.school_admin >= level && 
            (target_faculty.school_admin < level || 
            acting_faculty.school_admin > target_faculty.school_admin)
    end
    
      
    def verify_waiting_teachers_message
        "IMPORTANT: Some teachers are your school are waiting to be verified. Since you are an admin for #{@school.name}, will you please take a moment to verify the other teachers."
    end
    
end