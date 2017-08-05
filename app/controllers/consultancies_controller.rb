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
        
        check_if_date_already()
        check_if_ten()
        
        @teacher = @seminar.user
        @cThresh = @seminar.consultantThreshold
        @consultancy = Consultancy.create(:seminar => @seminar)
        
        @students = setup_present_students()
        @rankAssignsByNeed = rankAssignsByNeed(@seminar)
        @objectiveIds = @rankAssignsByNeed.map(&:id)
        @scores = ObjectiveStudent.where(objective_id: @objectiveIds)
        setupStudentHash()
        #setobjectivesAndScores(false)
        setupRankByConsulting()
        setupScoreHash()
        setupProfList()
        
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
        @consultancy = Consultancy.find(params[:id])
        @seminar = Seminar.find(params[:seminar])
        @teacher = @seminar.user
    end
    
    def index
        @seminar = Seminar.find(params[:seminar])
        @consultancies = Consultancy.where(:seminar => @seminar)
    end
    
    private
    
        def check_if_date_already()
            date = Date.today
            old_consult = @seminar.consultancies.where(:created_at => date.midnight..date.end_of_day).first
            old_consult.destroy if old_consult
        end
        
        def check_if_ten()
            if @seminar.consultancies.count > 9
                @seminar.consultancies.order('created_at asc').first.destroy
            end
        end
end