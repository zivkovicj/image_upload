class CommoditiesController < ApplicationController
    
    def new
        @commodity = Commodity.new
    end

    def index
        @commodities = Commodity.all
    end
    
    def edit
        @commodity = Commodity.find(params[:id])
    end
    
    def update
        @commodity = Commodity.find(params[:id])
        if @commodity.update(commodity_params)
          flash[:success] = "Item Updated"
          redirect_to current_user
        else
          render 'edit'
        end
    end
    
    private

        # Never trust parameters from the scary internet, only allow the white list through.
        def commodity_params
          params.require(:commodity).permit(:name, :image)
        end
end