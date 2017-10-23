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
  end
  
  def create
    name_protect
    @objective = Objective.new(objective_params)
    
    if @objective.save
      flash[:success] = "Objective Created"
      redirect_to quantities_objective_path(@objective)
    else # This actually shouldn't be able to happen right now, since the controller gives the objective a name
      new_objective_stuff()
      render 'new'
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
    name_protect
    @objective = Objective.find(params[:id])
    if current_user == @objective.user || current_user.type == "Admin" 
      this_redirect_path = quantities_objective_path(@objective)
      params_to_use = objective_params
    else
      this_redirect_path = current_user
      params_to_use = limited_objective_params
    end
    if @objective.update_attributes(params_to_use)
      flash[:success] = "Objective Updated"
      redirect_to this_redirect_path
    else
      @labels = labels_to_offer
      @pre_req_list = build_pre_req_list(@objective)
      render 'edit'
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
    
    redirect_to objectives_path
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
      @labels = labels_to_offer
      setPermissions(@objective)
      @pre_req_list = build_pre_req_list(@objective)
    end
    
    def name_protect
      params[:objective][:name] = "Objective #{Objective.count}" if params[:objective][:name].blank?
    end
          
          
end
