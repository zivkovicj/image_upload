class LabelsController < ApplicationController
  
  before_action :logged_in_user
  before_action only: [:delete, :destroy] do
    correct_owner(Label)
  end
  include SetPermissions

  def new
    @label = Label.new
    new_label_stuff()
    @questions = questions_to_offer
    setPermissions(@label)
  end

  def create
    @label = Label.new(label_params)
    
    if @label.save
      flash[:success] = "Label Created"
      redirect_to current_user
    else
      new_label_stuff()
      setPermissions(@label)
      @questions = questions_to_offer
      render 'new'
    end
  end

  def edit
    @label = Label.find(params[:id])
    @questions = questions_to_offer
    setPermissions(@label)
  end

  def update
    @label = Label.find(params[:id])
    
    if @label.update_attributes(label_params)
      flash[:success] = "Label Updated"
      redirect_to current_user
    else
      render 'edit'
    end
  end

  def index
    if current_user.type == "Admin"
      initial_list = Label.all.order(:name)
    else
      initial_list = Label.where("user_id = ? OR extent = ?", current_user.id, "public").order(:name)
    end

    if !params[:search].blank?
      second_list = initial_list.search(params[:search], params[:whichParam])
    else
      second_list = initial_list
    end
    
    @labels = second_list.paginate(page: params[:page])
  end

  def destroy
    @label = Label.find(params[:id])
    @label.questions.each do |quest|
      quest.update(:label_id => 1)
    end
    @label.pictures.each do |pic|
      pic.labels.delete(@label)
    end
    if @label.destroy
      flash[:success] = "Label Deleted"
      redirect_to labels_path
    end
  end
  
  private
  
    def label_params
      params.require(:label).permit(:name, :extent, :user_id, question_ids: [])
    end
    
    def questions_to_offer
      build_list = []
      question_list = (current_user.type == "Admin" ? Question.all : Question.where(:user => current_user))
      
      question_list.all.each do |question|
        build_list.push([question.id, question.short_prompt, question.label])
      end
      
      return build_list
    end
    
    def new_label_stuff()
      @label.user = current_user
      @label.extent = "public"
    end
end
