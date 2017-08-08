class ObjectiveSeminarsController < ApplicationController
    
    def edit

    end
    
    def update_pretests
        @seminar = Seminar.find(params[:seminar_id])
        @seminar.objective_seminars.where.not(:id => params[:pretest_on]).update_all(:pretest => 0)
        @seminar.objective_seminars.where(:id => params[:pretest_on]).update_all(:pretest => 1)
        redirect_to priorities_seminar_path(@seminar)
    end
    
    def update_priorities
        params[:syl].each do |key, value|
            @objective_seminar = ObjectiveSeminar.find(key)
            @objective_seminar.update(:priority => value)
        end
        redirect_to scoresheet_seminar_path(current_user.current_class)
    end
    
    
 
end