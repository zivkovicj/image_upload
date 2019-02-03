class WorksheetsController < ApplicationController
    
    def new
        @worksheet = Worksheet.new
    end
    
    def create
        #name_protect
        @worksheet = Worksheet.new(worksheet_params)
        #@worksheet.user = current_user
    
        if @worksheet.save
          flash[:success] = "File Successfully Uploaded"
          redirect_to current_user
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
          params.require(:worksheet).permit(:name, :file)
        end
    
end