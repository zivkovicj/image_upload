class SchoolsController < ApplicationController

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
                new_school_stuff
                render 'new'
            end
        else
            @teacher.update(:school_id => params[:this_school_id])
            redirect_to current_user
        end
    end
    
    def verify
        @school = School.find(params[:id])
        @unverified_teachers = @school.check_for_unverified_teachers
    end
    
    def verify_update
        @school = School.find(params[:id])
        params[:teacher].each do |id|
            new_teacher = Teacher.find(id)
            new_teacher.update(:verified => params[:teacher][:"#{id}"].to_i)
            new_teacher.sponsored_students.update_all(:school_id => @school.id)
        end
        redirect_to current_user
    end
    
    private
    
        def school_params
          params.require(:school).permit(:name, :city, :state, :mentor_id)
        end
        
        def new_school_stuff
            @school = School.new
            first_step = School.order(:name).paginate(page: params[:page])
            @all_schools = (params[:search].blank? ? first_step : first_step.search(params[:search], params[:whichParam]))
        end
end