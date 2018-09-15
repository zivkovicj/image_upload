class CommodityStudentsController < ApplicationController
    
    def index
        @teacher = User.find(params[:user_id])
        @com_studs = @teacher.commodities_needing_delivered.paginate(:per_page => 10, page: params[:page])
        @market_name = "#{@teacher.name_with_title} Market"
    end
    
    def update
        @com_stud = CommodityStudent.find(params[:id])
        @com_stud.update(:delivered => true)
    end
end
