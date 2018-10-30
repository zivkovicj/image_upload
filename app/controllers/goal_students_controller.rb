class GoalStudentsController < ApplicationController
    
    def index
        this_param = params[:seminar] || params[:format]
        @seminar = Seminar.find(this_param)
        goals_stuff
    end
    
    def print
       @seminar = Seminar.find(params[:seminar]) 
       goals_stuff
       render :layout => false
    end
    
    def edit
        @gs = GoalStudent.find(params[:id])
        redirect_to checkpoints_goal_student_path(@gs) if @gs.approved
    end
    
    def update
        @gs = GoalStudent.find(params[:id])
        if @gs.update_attributes(goal_student_params)
            @gs.gs_update_stuff
            flash[:success] = "Profile updated"
            redirect_to checkpoints_goal_student_path(@gs)
        else
            redirect_to student_view_seminar_path(@gs.seminar, :user => @gs.user.id)
        end
    end
    
    def checkpoints
       @gs = GoalStudent.find(params[:id])
       @seminar = @gs.seminar
       @term = @gs.term
    end
    
    def update_checkpoints
        @gs = GoalStudent.find(params[:id])
        if params[:syl]
            params[:syl].each do |key, value|
                @checkpoint = Checkpoint.find(key)
                @checkpoint.update(:action => value[:action])
            end
        end
        @ss = SeminarStudent.find_by(:seminar => @gs.seminar, :user => @gs.user)
        redirect_to seminar_student_path(@ss)
    end
    
    private
    
        def goal_student_params
            params.require(:goal_student).permit(:goal_id, :target, :approved)
        end
        
        def goals_stuff
            @seminar.update(:which_checkpoint => params[:which_checkpoint]) if params[:which_checkpoint]
            @this_term = @seminar.term
            @this_checkpoint = @seminar.which_checkpoint
        end
end