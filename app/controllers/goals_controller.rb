class GoalsController < ApplicationController
    
    include SetPermissions
    
    def new
        @goal = Goal.new(:user => current_user)
        @goal.actions = [[],[],[],[]]
        set_permissions(@goal)
    end
    
    def create
        @goal = Goal.new(goal_params)
        set_actions
        if @goal.save
            flash[:success] = "New Goal Created"
            redirect_to goals_path()
        else
          set_permissions(@goal)
          render 'new'
        end
    end
    
    def index
        @goals = Goal.where("user_id = ? OR extent = ?", current_user.id, "public").order(:name)
    end
    
    def edit
        @goal = Goal.find(params[:id])
        set_permissions(@goal)
    end
    
    def update
        @goal = Goal.find(params[:id])
        @goal.update_attributes(goal_params)
        set_actions
        if @goal.save
            flash[:success] = "Goal updated" 
            redirect_to goals_path
        else
            set_permissions(@goal)
            render 'edit'
        end
    end
    
    private
    
        def goal_params
            params.require(:goal).permit(:name, :extent, :user_id, :statement_stem)
        end
    
        def set_actions
           action_array = [[],[],[],[]]
            params[:goal][:actions].each do |level_x|
                x = level_x.to_i
                params[:goal][:actions][level_x].each do |level_y|
                    this_string = params[:goal][:actions][level_x][level_y]
                    action_array[x].push(this_string) if this_string.present?
                end
            end
            @goal.actions = action_array 
        end
    
end