module TeachersHelper
    
    def admin_rank_compared(acting_faculty, target_faculty, level)
        acting_faculty.school_admin >= level && 
            (target_faculty.school_admin < level || 
            acting_faculty.school_admin > target_faculty.school_admin)
    end
    
    def teacher_show_links
        [["Scoresheet", "scoresheet.png", "scoresheet_seminar", "scoresheet", "seminars"],
        ["Desk Consultants", "desk_consult.png", "consultancy", "show", "consultancies"],
        ["Goalkeeper", "apple.jpg", "goal_students", "index", "goal_students"],
        ["Edit", "E.png", "seminar", "show", "seminars"],
        ["Usernames", "usernames.png", "usernames_seminar", "usernames", "seminars"]]
    end
      
    def verify_waiting_teachers_message
        "IMPORTANT: Some teachers are your school are waiting to be verified. Since you are an admin for #{@school.name}, will you please take a moment to verify the other teachers."
    end
    
end