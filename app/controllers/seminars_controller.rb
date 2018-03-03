class SeminarsController < ApplicationController
    before_action :logged_in_user, only: [:create]
    before_action only: [:delete, :destroy, :show, :edit, :scoresheet, :seatingChart, :newChartByAchievement] do
        correct_owner(Seminar)
    end
    before_action :redirect_for_non_admin,    only: [:index] 
    
    include SetObjectivesAndScores
    
    def new
        @seminar = Seminar.new
        update_current_class
    end
    
    def create
        @seminar = current_user.own_seminars.build(seminar_params)
        if @seminar.save
            flash[:success] = "Class Created"
            update_current_class
            redirect_to edit_seminar_path(@seminar)
        else
            render 'seminars/new'
        end
    end

    def index
        if !params[:search].blank?
          @seminars = Seminar.paginate(page: params[:page]).search(params[:search], params[:whichParam])
        else
          @seminars = Seminar.paginate(page: params[:page])
        end
    end
  
    def show
        @seminar = Seminar.find(params[:id])
        @teacher = @seminar.user
        set_objectives_and_scores(false)
        @students = @seminar.students.order(:last_name)
        update_current_class
    end
    
    def edit
        @seminar = Seminar.find(params[:id])
        update_current_class
    end

    def update
        @seminar = Seminar.find(params[:id])
        set_checkpoint_due_dates
        set_priorities
        set_pretests
        @seminar.update_attributes(seminar_params)
        flash[:success] = "Class Updated"
        redirect_to edit_seminar_path(@seminar)
    end
    
    def destroy
        @seminar = Seminar.find(params[:id])
        @user = @seminar.user
        @seminar.destroy
        flash[:success] = "Class Deleted"
        redirect_to @user
    end
    
    
    
    
    ### Sub-menus for editing seminar
    
    def scoresheet
        @seminar = Seminar.find(params[:id])
        @teacher = @seminar.user
        @students = @seminar.students.order(:last_name)
        set_objectives_and_scores(false)
        update_current_class
    end
    
    def copy_due_dates
        @seminar = Seminar.find(params[:id])
        first_seminar = current_user.first_seminar
        @seminar.update(:checkpoint_due_dates => first_seminar.checkpoint_due_dates)
        flash[:success] = "Checkpoint Due Dates Updated"
        redirect_to edit_seminar_path(@seminar)
    end
    
    private 
        def seminar_params
            params.require(:seminar).permit(:name, :user_id, :consultantThreshold, objective_ids: [])
        end
        
        def correct_user
            @seminar = Seminar.find(params[:id])
            redirect_to(login_url) unless current_user && (current_user.own_seminars.include?(@seminar) || current_user.type == "Admin")
        end
        
        def set_checkpoint_due_dates
            date_array = [[],[],[],[]]
            params[:seminar][:checkpoint_due_dates].each do |level_x|
                x = level_x.to_i
                params[:seminar][:checkpoint_due_dates][level_x].each do |level_y|
                    y = level_y.to_i
                    this_date = params[:seminar][:checkpoint_due_dates][level_x][level_y]
                    date_array[x][y] = (this_date) if this_date.present?
                end
            end
            @seminar.checkpoint_due_dates = date_array 
        end
        
        def set_priorities
            if params[:priorities]
                params[:priorities].each do |key, value|
                    @objective_seminar = ObjectiveSeminar.find(key)
                    @objective_seminar.update(:priority => value)
                end
            end
        end
        
        def set_pretests
            @seminar.objective_seminars.where.not(:id => params[:pretest_on]).update_all(:pretest => 0)
            @seminar.objective_seminars.where(:id => params[:pretest_on]).update_all(:pretest => 1)
        end
        
end
