class SeminarsController < ApplicationController
    before_action :logged_in_user, only: [:create]
    before_action only: [:delete, :destroy, :show, :edit, :scoresheet, :seatingChart, :newChartByAchievement] do
        correct_owner(Seminar)
    end
    before_action :redirect_for_non_admin,    only: [:index] 
    
    include RankObjectivesByNeed
    include SetObjectivesAndScores
    include TeachAndLearnOptions
    
    def new
        @seminar = Seminar.new
        @seminar.consultantThreshold = 70
        current_user.update!(:current_class => @seminar.id)
    end
    
    def create
        @seminar = current_user.own_seminars.build(seminarParamsWithoutSeating)
        if @seminar.save
            flash[:success] = "Class Created"
            redirect_to scoresheet_url(@seminar)
        else
            render 'seminars/new'
        end
        current_user.update!(:current_class => @seminar.id) if @seminar.valid?
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
        current_user.update!(:current_class => @seminar.id)
    end
    
    def studentView
        @student = Student.find(params[:student])
        @seminar = Seminar.find(params[:id])
        @ss = @student.seminar_students.find_by(:seminar => @seminar)
        @teacher = @seminar.user
        
        rankAssignsByNeed = rankAssignsByNeed(@seminar)
        @teachOptions = teachOptions(@student, rankAssignsByNeed, @seminar.consultantThreshold, 10)
        @learnOptions = learnOptions(@student, rankAssignsByNeed, 10)
        
        set_objectives_and_scores(false)
        @student_scores = @student.objective_students.where(objective_id: @objectiveIds)
        
        blap = @student.teams.map(&:objective_id)
        @unlocked_by_desk_consult = @seminar.objectives.find(blap)
        
        current_user.update(:current_class => @seminar.id)
    end
    
    def scoresheet
        @seminar = Seminar.find(params[:id])
        @teacher = @seminar.user
        @students = @seminar.students.order(:last_name)
        set_objectives_and_scores(false)
        current_user.update!(:current_class => @seminar.id)
    end
    
    def seatingChart
        readySeating
    end
    
    def newChartByAchievement
        @seminar = Seminar.find(params[:id])
        @students = @seminar.students.order(:last_name)
        @teacher = @seminar.user
        set_objectives_and_scores(false)
        profList = @students.sort {|a,b| a.total_points <=> b.total_points}
        @tempSeating = []
        profList.each do |student|
            @tempSeating.push(student.id)
        end
        current_user.update!(:current_class => @seminar.id)
    end
    
    def edit
        @seminar = Seminar.find(params[:id])
        current_user.update!(:current_class => @seminar.id)
    end

    def update
        @seminar = Seminar.find(params[:id])
        #This section is a work-around because editing the class name was causing 
        #the seating parameter to save as a multi-dimensional array, which caused
        #it to fail.
        
        if params[:seminar][:seating]
            if @seminar.update_attributes(seminarParamsWithSeating)
                if @seminar.seating.class != "Array"
                    comegente = @seminar.seating
                    @seminar.seating = comegente.split(",")
                    @seminar.save
                end
                if @seminar.needSeat.class != "Array"
                    widower = @seminar.needSeat
                    @seminar.needSeat = widower.split(",")
                    @seminar.save
                end
                flash[:success] = "Class Updated"
            end
            current_user.update!(:current_class => @seminar.id)
            redirect_to seatingChart_url
        else
            if @seminar.update_attributes(seminarParamsWithoutSeating)
                flash[:success] = "Class Updated"
            end
            current_user.update!(:current_class => @seminar.id)
            redirect_to priorities_path(@seminar)
        end
    end
    
    def priorities
        @seminar = Seminar.find(params[:id])
        @os = @seminar.objective_seminars.sort_by{|x| [x.objective.name]}
        current_user.update!(:current_class => @seminar.id)
    end
    
    def destroy
        @seminar = Seminar.find(params[:id])
        @user = @seminar.user
        @seminar.destroy
        flash[:success] = "Class Deleted"
        redirect_to @user
    end
    
    def to_boolean(str)
        str == 'true'
    end

    
    private 
        def readySeating
            @seminar = Seminar.find(params[:id])
            @teacher = @seminar.user
            @students = @seminar.students.order(:last_name)
            #if @seminar.seating.blank?
                #tempSeating = []
                #@students.each do |student|
                    #tempSeating.push(student.id)
                #end
                #@seminar.seating = tempSeating
                #@seminar.save
            #end
            #if @seminar.needSeat.blank?  #This is just in case people started their accounts before I added the needSeat feature
               #@seminar.needSeat = []
               #@seminar.save
            #end
            current_user.update!(:current_class => @seminar.id)
        end
        
        def seminarParamsWithSeating
            params.require(:seminar).permit(:seating, :needSeat)
        end
        
        def seminarParamsWithoutSeating
            params.require(:seminar).permit(:name, :user_id, :consultantThreshold, objective_ids: [])
        
        end
        
        def correct_user
            @seminar = Seminar.find(params[:id])
            redirect_to(login_url) unless current_user && (current_user.own_seminars.include?(@seminar) || current_user.type == "Admin")
        end
        
end
