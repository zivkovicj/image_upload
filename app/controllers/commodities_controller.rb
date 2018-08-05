class CommoditiesController < ApplicationController
    
    before_action :is_school_admin, :except => [:index, :update]
    
    def new
        @commodity = Commodity.new
        @school_id = params[:school_id]
    end
    
    def create
        @commodity = Commodity.new(commodity_params)
        if @commodity.save
            @school = @commodity.school
            if @school
                flash[:success] = "New Item Created for #{@school.market_name}"
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
        @student = current_user
        @seminar = nil
        @commodities = @school.commodities.paginate(:per_page => 6, page: params[:page])
        @bucks_current = current_user.bucks_current(:school, @school) if current_user.type == "Student"
        @school_or_seminar = "school"
    end
    
    def edit
        @commodity = Commodity.find(params[:id])
    end
    
    def update
        @commodity = Commodity.find(params[:id])
        if params[:use]
            commodity_use
        elsif params[:multiplier]
            commodity_buy
        elsif @commodity.update(commodity_params)
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

        def commodity_params
          params.require(:commodity).permit(:name, :image, :school_id, :current_price, :quantity, :salable)
        end
        
        def commodity_buy
            @multiplier = params[:multiplier].to_i
            @student = Student.find(params[:student_id])
            if params[:school_or_seminar] == "seminar"
                bucks_to_check = @student.bucks_current(:seminar_id, params[:seminar_id])
            else
                bucks_to_check = @student.bucks_current(:school, @student.school)
            end
            
            sell_allowed = @multiplier < 0 && @student.com_quant(@commodity) > 0
            buy_allowed = @multiplier > 0 && bucks_to_check > 0 && @commodity.quantity > 0
            if buy_allowed || sell_allowed
                price_paid = @commodity.current_price * @multiplier
                @student.commodity_students.create(:commodity => @commodity, :quantity => @multiplier, 
                    :price_paid => price_paid, :seminar_id => params[:seminar_id], :school_id => params[:school_id])
              
                old_quant = @commodity.quantity
                @commodity.update(:quantity => old_quant - 1)
            end
        end
      
        def commodity_use
            @student = Student.find(params[:student_id])
            @student.commodity_students.create(:commodity => @commodity, :quantity => -1, :price_paid => 0)
        end
end