class CheckpointsController < ApplicationController
    
    def update
        @checkpoint = Checkpoint.find(params[:id])
        @checkpoint.update_attributes(checkpoint_params)
        #respond_with @checkpoint
    end
    
    
    private
    
        def checkpoint_params
            params.require(:checkpoint).permit(:achievement, :teacher_comment, :student_comment, :action)
        end
end