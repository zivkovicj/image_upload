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
        @bucks_owned = current_user.school_bucks_owned
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
        
        def set_or_create_com_stud
            @multiplier = params[:multiplier].to_i
            @student = Student.find(params[:student_id])
            @this_com_stud = CommodityStudent.find_or_create_by(:user => @student, :commodity => @commodity)
            
            @buck_source = params[:school_or_seminar]
            if @buck_source == "school"
                @source_model = @student
                @bucks_to_use = @student.school_bucks_owned
                @sell_allowed = false
            else
                @seminar = Seminar.find(params[:seminar_id])
                @source_model = @student.seminar_students.find_by(:seminar => @seminar)
                @bucks_to_use = @source_model.seminar_bucks_owned
                @sell_allowed = @multiplier < 0 && @this_com_stud.quantity > 0
            end
        end
        
        def commodity_buy
            set_or_create_com_stud
            
            buy_allowed = @multiplier > 0 && @bucks_to_use > 0 && @commodity.quantity > 0
            if buy_allowed || @sell_allowed
              @this_com_stud.update(:quantity => @this_com_stud.quantity + @multiplier)
              
              cost = (@commodity.current_price * @multiplier)
              old_bucks = @source_model.read_attribute(:"#{@buck_source}_bucks_owned")
              @source_model.update(:"#{@buck_source}_bucks_owned" => old_bucks - cost)
              old_quant = @commodity.quantity
              @commodity.update(:quantity => old_quant - 1)
            end
        end
      
        def commodity_use
            set_or_create_com_stud
            @this_com_stud.update(:quantity => @this_com_stud.quantity - 1)
            
            term = @seminar.term_for_seminar
            old_stars = @source_model.stars_used_toward_grade[term]
            @source_model.stars_used_toward_grade[term] = old_stars + 1
            @source_model.save
        end
end