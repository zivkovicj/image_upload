class CommodityStudentsController < ApplicationController
    
    def index
        @school = School.find(params[:school_id])
        @com_studs = @school.commodities_needing_delivered.paginate(:per_page => 6, page: params[:page])
    end
    
    def update
        @com_stud = CommodityStudent.find(params[:id])
        @com_stud.update(:quant_delivered => @com_stud.quant_delivered + 1)
    end
end
