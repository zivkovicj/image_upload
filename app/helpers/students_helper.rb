module StudentsHelper
    
    def confirm_remove_student
        "Click here to confirm that you want to remove #{@student.first_name} from #{@seminar.name}"
    end
    
    def school_year_array
       ["P","K",1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16] 
    end
end
