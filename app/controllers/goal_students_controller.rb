class GoalStudentsController < ApplicationController
    

    
    def approve
       @seminar = Seminar.find(params[:id])
       goals_stuff
    end
    
    def index
       @seminar = Seminar.find(params[:seminar])
       redirect_to approve_goal_student_path(@seminar) unless @seminar.goals_needing_approval == 0 || params[:override]
       goals_stuff
    end
    
    def print
       @seminar = Seminar.find(params[:seminar]) 
       goals_stuff
    end
    
    def edit
        @goal_student = GoalStudent.find(params[:id])
    end
    
    def update
        @gs = GoalStudent.find(params[:id])
        @gs.update_attributes(goal_student_params)
        if @gs.goal_id.present?
            @gs.gs_update_stuff
            flash[:success] = "Profile updated"
            redirect_to checkpoints_goal_student_path(@gs)
        else
            redirect_to student_view_seminar_path(@gs.seminar, :user => @gs.user.id)
        end
    end
    
    def checkpoints
       @gs = GoalStudent.find(params[:id])
    end
    
    def update_checkpoints
        @gs = GoalStudent.find(params[:id])
        if params[:syl]
            params[:syl].each do |key, value|
                @checkpoint = Checkpoint.find(key)
                @checkpoint.update(:action => value[:action])
            end
        end
        redirect_to student_view_seminar_path(@gs.seminar, :user => @gs.user.id)
    end
    
    private
    
        def goal_student_params
            params.require(:goal_student).permit(:goal_id, :target, :approved)
        end
        
        def goals_stuff
            @seminar.update(:which_checkpoint => params[:which_checkpoint]) if params[:which_checkpoint]
            @seminar.update(:term => params[:term]) if params[:term]
            @this_term = @seminar.term
            @this_checkpoint = @seminar.which_checkpoint
        end
end