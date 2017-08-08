class ObjectivesController < ApplicationController
  
  before_action only: [:delete, :destroy] do
    correct_owner(Objective)
  end
  
  include BuildPreReqLists
  include SetPermissions
  include LabelsList
  
  
  def new
    @objective = Objective.new()
    new_objective_stuff()
    @labels = labels_to_offer
    setPermissions(@objective)
    @pre_req_list = build_pre_req_list(@objective)
  end
  
  def create
    @objective = Objective.new(objective_params)
    if @objective.name.blank?
      @objective.name = "Objective #{Objective.count}"  
    end
    
    if @objective.save
      flash[:success] = "Objective Created"
      redirect_to quantities_objective_path(@objective)
    else
      new_objective_stuff()
      setPermissions(@objective)
      @pre_req_list = build_pre_req_list(@objective)
      render 'objectives/new'
    end
  end
  
  def index
    if !params[:search].blank?
      if current_user.type == "Admin"
        @objectives = Objective.paginate(page: params[:page]).search(params[:search], params[:whichParam])
      else
        @objectives = Objective.where("user_id = ? OR extent = ?", current_user, "public").paginate(page: params[:page]).search(params[:search], params[:whichParam])
      end
    end
    
    if current_user.type == "Admin"
      @objectives ||= Objective.paginate(page: params[:page])
    elsif current_user.type == "Student"
      redirect_to login_url
    else
      @objectives ||= Objective.where("user_id = ? OR extent = ?", current_user.id, "public").paginate(page: params[:page])
    end
  end

  def edit
    @objective = Objective.find(params[:id])
    @labels = labels_to_offer

    setPermissions(@objective)
    @pre_req_list = build_pre_req_list(@objective)
  end

  def update
    @objective = Objective.find(params[:id])
    newName = params[:objective][:name] 
    if newName.blank?
      params[:objective][:name] = @objective.name 
    end
    if current_user.id == @objective.user_id || current_user.type =="Admin"
      if @objective.update_attributes(objective_params)
        flash[:success] = "Objective Updated"
        redirect_to quantities_objective_path(@objective)
      else
        @labels = labels_to_offer
        @pre_req_list = build_pre_req_list(@objective)
        render 'edit'
      end
    else
      if @objective.update_attributes(limited_objective_params)
        flash[:success] = "Objective Updated"
        redirect_to current_user
      else
        @labels = labels_to_offer
        @pre_req_list = build_pre_req_list(@objective)
        render 'edit'
      end
    end
  end
  
  def quantities
    @objective = Objective.find(params[:id])
    @label_objectives = @objective.label_objectives.sort_by{|x| [x.label.name]}
  end

  def destroy
    @objective = Objective.find(params[:id])
    
    ObjectiveStudent.where(:objective_id => @objective.id).each do |as|
      as.destroy!
    end
    oldAssignId = @objective.id
    @objective.destroy
    SeminarStudent.all.each do |ss|
      if ss.teach_request == oldAssignId
        ss.update(:teach_request => nil)
      end
      
      if ss.learn_request == oldAssignId
        ss.update(:learn_request => nil)
      end
    end
    flash[:success] = "Objective Deleted"
    
    redirect_to current_user
  end
  
  private
        def objective_params
            params.require(:objective).permit(:name, :extent, :user_id, preassign_ids: [], seminar_ids: [], label_ids: [])
        end
        
        def limited_objective_params
            params.require(:objective).permit(seminar_ids: [])
        end
        
        def new_objective_stuff
          @objective.name = "Objective #{Objective.count}"
          @objective.user = current_user
          @objective.extent = "public"
        end
          
          
end
