class LabelObjectivesController < ApplicationController
    
    def edit

    end
    
    def update_quantities
        if params[:syl]
            params[:syl].each do |key, value|
                @lo = LabelObjective.find(key)
                @lo.update(:quantity => value[:quantity])
                @lo.update(:point_value => value[:point_value])
            end
        end
        redirect_to current_user
    end
 
end