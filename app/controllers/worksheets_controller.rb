class WorksheetsController < ApplicationController
    
    def new
        @worksheet = Worksheet.new
    end
    
    def create
      @worksheet = Worksheet.new(worksheet_params)
      @worksheet.user = current_user
  
      if @worksheet.save
        flash[:success] = "File Successfully Uploaded"
        this_obj_id = params[:worksheet][:objective] 
        if this_obj_id == nil
          redirect_to current_user
        else
          @objective = Objective.find_by(this_obj_id)
          @worksheet.objectives << @objective
          redirect_to @objective
        end
      else
        render 'new'
      end
    end 
    
    def index
      @worksheets = Worksheet.all
    end
    
    def destroy
      @worksheet = Worksheet.find(params[:id])
      @worksheet.destroy
      flash[:success] = "File Deleted"
      redirect_to worksheets_path
    end
    
    private
    
        def worksheet_params
          params.require(:worksheet).permit(:name, :uploaded_file)
        end
    
end