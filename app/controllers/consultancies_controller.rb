class ConsultanciesController < ApplicationController
    
    include DeskConsultants

    def new
        @seminar = Seminar.find(params[:seminar])
        @students = @seminar.students.order(:last_name)
        current_user.update(:current_class => @seminar.id)
        @consultancy = Consultancy.new()
    end
    
    def create
        @seminar = Seminar.includes(:seminar_students).find(params[:consultancy][:seminar])
        
        check_if_date_already
        check_if_ten
        
        @cThresh = @seminar.consultantThreshold
        @consultancy = Consultancy.create(:seminar => @seminar)
        
        @students = setup_present_students
        @rank_objectives_by_need = @seminar.rank_objectives_by_need
        @rank_by_consulting = setup_rank_by_consulting
        @need_hash = setup_need_hash
        @prof_list = setup_prof_list
        
        # Each function in these steps is only called once. But I wrote them as
        # separate functions in order to better test the individual pieces.
        choose_consultants
        place_apprentices_by_requests
        place_apprentices_by_mastery
        check_for_lone_students
        new_place_for_lone_students
        are_some_unplaced
        
        current_user.update!(:current_class => @seminar.id)
        render 'show'
    end
    
    def show
        if params[:consultancy_id].present?
            @consultancy = Consultancy.find(params[:consultancy_id])
            @seminar = @consultancy.seminar
        else
            @seminar = Seminar.find(params[:id])
            @consultancy = @seminar.consultancies.order(:created_at).last
            redirect_to new_consultancy_path(:seminar => @seminar.id) if @consultancy.blank?
        end
    end
    
    def index
        @seminar = Seminar.find(params[:seminar])
        @consultancies = Consultancy.where(:seminar => @seminar).order(:updated_at)
    end
    
    def destroy
        @consultancy = Consultancy.find(params[:id])
        @seminar = @consultancy.seminar
    
        if @consultancy.destroy
            flash[:success] = "Arrangement Deleted"
            redirect_to consultancies_path(:seminar => @seminar.id)
        end
    end
    
    def edit
        @consultancy = Consultancy.find(params[:id])
        @consultancy.update(:duration => "permanent")
        give_dc_keys
        update_all_consultant_days
        redirect_to controller: 'consultancies', action: 'show', id: @consultancy.id, consultancy_id: @consultancy.id
    end
    
    private
        def check_if_date_already
            date = Date.today
            old_consult = @seminar.consultancies.find_by(:created_at => date.midnight..date.end_of_day)
            old_consult.destroy if old_consult
        end
        
        def check_if_ten
            if @seminar.consultancies.count > 9
                @seminar.consultancies.order('created_at asc').first.destroy
            end
        end
        
        def give_dc_keys
          @consultancy.teams.each do |team|
            ObjectiveStudent.where(:user_id => team.user_ids, :objective_id => team.objective_id).each do |obj_stud|
              obj_stud.update_keys("dc", 2) unless obj_stud.points_this_term == 10
            end
          end
        end
        
        def update_all_consultant_days
            all_consultants = @consultancy.all_consultants
            SeminarStudent.where(:seminar => @consultancy.seminar, :user => all_consultants).each do |ss|
                ss.set_last_consultant_day(@consultancy.created_at)
            end
        end
end