module AddStudentStuff
    extend ActiveSupport::Concern


    

    

    def calculate_percentile(array, percentile)
        array.sort[(percentile * array.length).ceil - 1]
    end
    
        
end