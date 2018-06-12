class SeminarsController < ApplicationController
    before_action :logged_in_user, only: [:create]
    before_action :redirect_for_non_admin,    only: [:index]
    before_action :correct_user, only: [:destroy]
    
    
    def new
        @seminar = Seminar.new
        update_current_class
    end
    
    def create
        @seminar = Seminar.new(seminar_params)
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
        @teachers = @seminar.teachers
        gather_objectives_and_scores
        @students = @seminar.students.order(:last_name)
        update_current_class
    end
    
    def edit
        @seminar = Seminar.find(params[:id])
        @teacher = current_user
        @school = @teacher.school if @teacher.verified
        @objectives = @seminar.objectives.order(:name)
        @this_teacher_can_edit = @teacher.can_edit_this_seminar(@seminar)
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
        @seminar.destroy
        flash[:success] = "Class Deleted"
        redirect_to current_user
    end
    
    ### Sub-menus for editing seminar
    
    def scoresheet
        @seminar = Seminar.find(params[:id])
        @teacher = current_user
        @students = @seminar.students.order(:last_name)
        @term = params[:term].to_i
        @show_all = params[:show_all]
        gather_objectives_and_scores
        update_current_class
    end
    
    def update_scoresheet
        @seminar = Seminar.find(params[:id])
        this_term = params[:term].to_i
        params[:scores].each do |key, value|
            this_val = Integer(value) rescue nil
            if this_val
                @this_obj_stud = ObjectiveStudent.find(key)
                @this_obj_stud.update_scores(this_val, this_term, "teacher_granted", true) unless @this_obj_stud.current_scores[this_term] == this_val
            end
        end
        redirect_to scoresheet_seminar_path(@seminar, :term => this_term)
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
            redirect_to(login_url) unless current_user && (current_user.type == "Admin" || current_user.can_edit_this_seminar(@seminar))
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
        
        def gather_objectives_and_scores
            pre_objectives = @seminar.objectives.order(:name)
            @scores = ObjectiveStudent.where(:objective => pre_objectives, :user => @seminar.students)
            if @show_all == "true"
                @objectives = pre_objectives
            else
                @objectives = []
                pre_objectives.each do |obj|
                    @objectives << obj if @scores.select{|x| x.current_scores[@term]}.count > 0
                end
            end
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
            @seminar.objective_seminars.where.not(:id => params[:pretest_on]).each do |obj_sem|
                obj_sem.update(:pretest => 0)
                @seminar.students.each do |stud|
                    this_obj_stud = stud.objective_students.find_by(:objective => obj_sem.objective)
                    this_obj_stud.update(:pretest_keys => 0) if this_obj_stud
                end
            end
            @seminar.objective_seminars.where(:id => params[:pretest_on]).each do |obj_sem|
                obj_sem.update(:pretest => 1)
                @seminar.students.each do |stud|
                    this_obj_stud = stud.objective_students.find_by(:objective => obj_sem.objective)
                    this_obj_stud.update(:pretest_keys => 2) if this_obj_stud
                end
            end
        end
        
end
