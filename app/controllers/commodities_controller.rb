class CommoditiesController < ApplicationController
    
    before_action :is_school_admin, :except => [:index]
    
    def new
        @commodity = Commodity.new
        @school_id = params[:school_id]
    end
    
    def create
        @commodity = Commodity.new(commodity_params)
        if @commodity.save
            flash[:success] = "New Item Created for School Market"
            @school = @commodity.school
            if @school
                redirect_to commodities_path(:school_id => @school.id)
            else
                redirect_to login_url 
            end
        else
            render 'new'
        end
    end

    def index
        @school = School.find(params[:school_id])
        @commodities = @school.commodities.paginate(:per_page => 8, page: params[:page])
        @bucks_owned = current_user.school_bucks_owned
    end
    
    def edit
        @commodity = Commodity.find(params[:id])
    end
    
    def update
        @commodity = Commodity.find(params[:id])
        if @commodity.update(commodity_params)
            flash[:success] = "Item Updated"
            redirect_to commodities_path(:school_id => @commodity.school_id)
        else
          render 'edit'
        end
    end
    
    def destroy
        @commodity = Commodity.find(params[:id])
        school_id = @commodity.school_id
        @commodity.destroy
        flash[:success] = "Item Deleted"
        
        redirect_to commodities_path(:school_id => school_id)
    end
    
    private

        # Never trust parameters from the scary internet, only allow the white list through.
        def commodity_params
          params.require(:commodity).permit(:name, :image, :school_id, :current_price, :quantity)
        end
end