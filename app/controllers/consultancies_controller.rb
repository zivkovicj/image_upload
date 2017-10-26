class ConsultanciesController < ApplicationController
    
    include DeskConsultants
    include RankObjectivesByNeed

    def new
        @seminar = Seminar.find(params[:seminar])
        @teacher = @seminar.user
        @students = @seminar.students.order(:last_name)
        current_user.update(:current_class => @seminar.id)
        @consultancy = Consultancy.new()
    end
    
    def create
        @seminar = Seminar.includes(:seminar_students).find(params[:consultancy][:seminar])
        @oss = @seminar.objective_seminars.includes(:objective).order(:priority)
        
        check_if_date_already
        check_if_ten
        
        @teacher = @seminar.user
        @cThresh = @seminar.consultantThreshold
        @consultancy = Consultancy.create(:seminar => @seminar)
        
        @students = setup_present_students()
        @rankAssignsByNeed = rankAssignsByNeed(@seminar)
        @objectiveIds = @rankAssignsByNeed.map(&:id)
        setupStudentHash
        #setobjectivesAndScores(false)
        @rank_by_consulting = setup_rank_by_consulting
        setupScoreHash
        setupProfList
        
        # Each function in these steps is only called once. But I wrote them as
        # separate functions in order to better test the individual pieces.
        chooseConsultants()
        placeApprenticesByRequests()
        placeApprenticesByMastery()
        checkForLoneStudents()
        newPlaceForLoneStudents()
        # assignSGSections()
        areSomeUnplaced()
        
        current_user.update!(:current_class => @seminar.id)
        render 'show'
    end
    
    def show
        if params[:seminar].present?
            @seminar = Seminar.find(params[:seminar])
            @consultancy = @seminar.consultancies.order(:created_at).last
            redirect_to new_consultancy_path(:seminar => @seminar.id) if @consultancy.blank?
        else
            @consultancy = Consultancy.find(params[:id])
            @seminar = @consultancy.seminar
        end
        @teacher = @seminar.user
    end
    
    def index
        @seminar = Seminar.find(params[:seminar])
        @consultancies = Consultancy.where(:seminar => @seminar)
    end
    
    def destroy
        @consultancy = Consultancy.find(params[:id])
        @seminar = @consultancy.seminar
    
        if @consultancy.destroy
            flash[:success] = "Arrangement Deleted"
            redirect_to consultancies_path(:seminar => @seminar.id)
        end
    end
    
    private
    
        def check_if_date_already()
            date = Date.today
            old_consult = @seminar.consultancies.find_by(:created_at => date.midnight..date.end_of_day)
            old_consult.destroy if old_consult
        end
        
        def check_if_ten()
            if @seminar.consultancies.count > 9
                @seminar.consultancies.order('created_at asc').first.destroy
            end
        end
end