module ConsultanciesHelper
    
    def new_consultancy_button_text
        "Create Desk Consultants Groups"
    end
    
    def new_consultancy_headline
        "Mark Attendance Before Creating Desk-Consultants Groups"
    end
    
    def no_consultancies_message
        "This class has no saved arrangements." 
    end
    
    def show_consultancy_headline(consultancy)
        "Groups for #{consultancy.display_date}"
    end
end
