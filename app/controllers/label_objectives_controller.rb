class LabelObjectivesController < ApplicationController
    
    def edit

    end
    
    def update
        params[:syl].each do |key, value|
            @lo = LabelObjective.find(key)
            @lo.update(:quantity => value[:quantity])
            @lo.update(:point_value => value[:point_value])
        end
        redirect_to user_path(current_user)
    end
 
end