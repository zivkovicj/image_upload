class SeminarsController < ApplicationController
    before_action :logged_in_user, only: [:create]
    before_action only: [:delete, :destroy, :show, :edit, :scoresheet, :seatingChart, :newChartByAchievement] do
        correct_owner(Seminar)
    end
    before_action :redirect_for_non_admin,    only: [:index] 
    
    include SetObjectivesAndScores
    include TeachAndLearnOptions
    
    def new
        @seminar = Seminar.new
        update_current_class
    end
    
    def create
        @seminar = current_user.own_seminars.build(seminarParamsWithoutSeating)
        if @seminar.save
            flash[:success] = "Class Created"
            update_current_class
            pretest_or_not
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
            update_current_class
            redirect_to seatingChart_url
        else
            if @seminar.update_attributes(seminarParamsWithoutSeating)
                flash[:success] = "Class Updated"
            end
            update_current_class
            pretest_or_not
        end
    end
    
    def destroy
        @seminar = Seminar.find(params[:id])
        @user = @seminar.user
        @seminar.destroy
        flash[:success] = "Class Deleted"
        redirect_to @user
    end
    
    def newChartByAchievement
        @seminar = Seminar.find(params[:id])
        @students = @seminar.students.order(:last_name)
        @teacher = @seminar.user
        set_objectives_and_scores(false)
        profList = @students.sort {|a,b| a.total_stars(@seminar) <=> b.total_stars(@seminar)}
        @tempSeating = []
        profList.each do |student|
            @tempSeating.push(student.id)
        end
        update_current_class
    end
    
    def pretests
        @seminar = Seminar.find(params[:id])
        @os = @seminar.objective_seminars.sort_by{|x| [x.objective.name]}
        update_current_class
    end
    
    def priorities
        @seminar = Seminar.find(params[:id])
        @os = @seminar.objective_seminars.sort_by{|x| [x.objective.name]}
        update_current_class
    end

    def scoresheet
        @seminar = Seminar.find(params[:id])
        @teacher = @seminar.user
        @students = @seminar.students.order(:last_name)
        set_objectives_and_scores(false)
        update_current_class
    end
    
    def seatingChart
        readySeating
    end
    
    def student_view
        @student = Student.includes(:objective_students).find(params[:user])
        @seminar = Seminar.includes(:objective_seminars).find(params[:id])
        @oss = @seminar.objective_seminars.includes(:objective).order(:priority)
        @objectives = @seminar.objectives.order(:name)
        objective_ids = @objectives.map(&:id)
        @student_scores = @student.objective_students.where(:objective_id => objective_ids)
        
        @ss = @student.seminar_students.find_by(:seminar => @seminar) # Is this needed?
        @teacher = @seminar.user
        
        @teach_options = teach_options(@student, @seminar, 5)
        @learn_options = learn_options(@student, @seminar, 5)
        
        @unfinished_quizzes = @student.all_unfinished_quizzes(@seminar)
        @desk_consulted_objectives = @student.desk_consulted_objectives(@seminar)
        @all_pretest_objectives = @seminar.all_pretest_objectives(@student)
        
        @show_quizzes = @desk_consulted_objectives.present? || @all_pretest_objectives.present? || @unfinished_quizzes.present?
        
        update_current_class
    end
    
    def pretest_or_not
        next_path = @seminar.objectives.present? ? pretests_seminar_path(@seminar) : scoresheet_seminar_path(@seminar)
        redirect_to next_path
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
            update_current_class
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
        
        def update_current_class
            current_user.update(:current_class => @seminar.id)
        end
        
end
