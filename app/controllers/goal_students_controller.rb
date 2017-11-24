class GoalStudentsController < ApplicationController
    
    def edit
        @goal_student = GoalStudent.find(params[:id])
    end
    
    def update
        @gs = GoalStudent.find(params[:id])
        @gs.update_attributes(goal_student_params)
        if @gs.goal_id.present?
            @gs.update(:goal => Goal.find(@gs.goal_id))
            flash[:success] = "Profile updated"
            redirect_to checkpoints_goal_student_path(@gs)
        else
            redirect_to student_view_seminar_path(@gs.seminar, :user => @gs.user.id)
        end
    end
    
    def checkpoints
       @gs = GoalStudent.find(params[:id])
       
        @action_array = []
        8.times do |n|
            this_action = @gs.goal.read_attribute(:"action_#{n}")
            @action_array.push(this_action) if this_action
        end
        
        @second_action_array = []
        3.times do |n|
            this_action = @gs.goal.read_attribute(:"second_action_#{n}")
            @second_action_array.push(this_action) if this_action
        end
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
end