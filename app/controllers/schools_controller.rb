class SchoolsController < ApplicationController
    
    before_action :is_mentor

    def new
       @teacher = Teacher.find(params[:teacher_id])
       new_school_stuff
    end
    
    def create
        @teacher = Teacher.find(params[:school][:mentor_id])
        if params[:school][:name].present?
            @school = School.new(school_params)
            if @school.save
                @teacher.update(:school => @school, :verified => 1)
                flash[:success] = "Welcome to Mr.Z School!"
                redirect_to current_user
            else
                flash[:danger] = "Please complete all information for your school"
                new_school_stuff
                render 'new'
            end
        elsif params[:this_school_id].present?
            @teacher.update(:school_id => params[:this_school_id])
            redirect_to current_user
        else
            flash[:danger] = "Please choose a school or create a new school."
            new_school_stuff
            render 'new'
        end
    end
    
    def edit
        @school = School.find(params[:id])
    end
    
    def update
        @school = School.find(params[:id])
        set_term_dates
        @school.update_attributes(school_params)
        flash[:success] = "#{@school.name} Updated"
        redirect_to current_user
    end
    
    def verify
        @school = School.find(params[:id])
        @unverified_teachers = @school.unverified_teachers
    end
    
    def verify_update
        @school = School.find(params[:id])
        params[:teacher].each do |id|
            new_teacher = Teacher.find(id)
            new_teacher.update(:verified => params[:teacher][:"#{id}"].to_i)
            new_teacher.sponsored_students.update_all(:verified => 1) if new_teacher.verified == 1
        end
        redirect_to current_user
    end
    
    private
    
        def school_params
          params.require(:school).permit(:name, :city, :state, :mentor_id)
        end
        
        def new_school_stuff
            @school = School.new
            first_step = School.order(created_at: :desc)
            second_step = (params[:search].blank? ? first_step : first_step.search(params[:search], params[:whichParam]))
            @all_schools = second_step.limit(10)
        end
        
        def is_mentor
            if params[:id]
                @school = School.find(params[:id])
                redirect_to current_user unless @school.mentor == current_user || user_is_an_admin
            end
        end
        
        def set_term_dates
            date_array = [[],[],[],[]]
            params[:school][:term_dates].each do |level_x|
                x = level_x.to_i
                params[:school][:term_dates][level_x].each do |level_y|
                    y = level_y.to_i
                    this_date = params[:school][:term_dates][level_x][level_y]
                    date_array[x][y] = (this_date) if this_date.present?
                end
            end
            @school.term_dates = date_array
        end
end