module StudentsHelper
    
    def confirm_remove_student
        "Click here to confirm that you want to remove #{@student.first_name} from #{@seminar.name}"
    end
end
