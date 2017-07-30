class ObjectiveSeminarsController < ApplicationController
    
    def edit

    end
    
    def update
        params[:syl].each do |key, value|
            @objective_seminar = ObjectiveSeminar.find(key)
            @objective_seminar.update(:priority => value)
        end
        redirect_to scoresheet_path(current_user.current_class)
    end
 
end