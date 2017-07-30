class QuestionsController < ApplicationController
  
  include SetPermissions
  include LabelsList
  
  def new
    new_question_stuff()
    setPermissions(@question)
  end

  def create
    one_saved = false
    
    params["questions"].each do |question|
      if params["questions"][question][:prompt].blank? == false
        @question = Question.new(multi_params(params["questions"][question]))
        @question.user_id = params[:user_id]
        @question.label_id = params[:label]
        @question.extent = params[:extent]
        ensure_essentials()
        correct_num = set_correct_num(params["questions"][question][:whichIsCorrect])
        set_correct_answers(correct_num)
        one_saved = true if @question.save
      end
    end
    
    if one_saved
      flash[:success] = "Questions Created"
      redirect_to user_path(current_user)
    else
      new_question_stuff()
      setPermissions(@question)
      render 'new'
    end
  end

  def index
    @labels = labels_to_offer
    @labels_to_check = []
    
    if params[:label_ids].blank?
      initial_list = Question.all
    else
      params[:label_ids].each do |label_id|
        num = (label_id == "on" ? nil : label_id.to_i)
        @labels_to_check.push(num)
      end
      initial_list = Question.where(label_id: params[:label_ids])
    end
    
    if current_user.role == "admin"
      second_list = initial_list
    else
      second_list = initial_list.where("user_id = ? OR extent = ?", current_user.id, "public")
    end
    
    if !params[:search].blank?
      third_list = second_list.search(params[:search], params[:whichParam])
    else
      third_list = second_list
    end
    
    @questions = third_list.order(:prompt).paginate(page: params[:page])
  end

  def show
  end

  def edit
    @question = Question.find(params[:id])
    @labels = labels_to_offer()
    setPermissions(@question)
  end

  def update
    @question = Question.find(params[:id])
    ensure_essentials()
    correct_num = set_correct_num(params[:question][:whichIsCorrect])
    set_correct_answers(correct_num)
    if @question.update_attributes(question_params)
      flash[:success] = "Question Updated"
      redirect_to user_path(current_user)
    else
      render 'edit'
    end
  end

  def destroy
  end
  
  private
    def question_params
      params.require(:question).permit(:prompt, :extent, :user_id, :label_id,
        :choice_0, :choice_1, :choice_2, :choice_3, :choice_4, :choice_5, :picture_id)
    end
    
    def multi_params(my_params)
      my_params.permit(:prompt, :choice_0, :choice_1, :choice_2, :choice_3,
        :choice_4, :choice_5)
    end
    
    def ensure_essentials()
      @question.update(:choice_0 => "First Choice") if @question.choice_0.blank?
      @question.update(:choice_1 => "Second Choice") if @question.choice_1.blank?
    end
    
    def set_correct_num(param_num)
      a = param_num ? param_num.to_i : 0
      return a
    end
    
    def set_correct_answers(correct_num)
      correct_value = @question.read_attribute(:"choice_#{correct_num}")
      correct_value ||= "Correct Answer"
      correct_array = []
      correct_array.push(correct_value)
      @question.update(:correct_answers => correct_array)
    end
    
    def new_question_stuff()
      label_1 = Label.find(1)
      @question_group = []
      5.times do
        @question_group << Question.new(:user_id => current_user.id, :label_id => label_1.id)
      end
      @labels = labels_to_offer()
      @question = @question_group[0]
    end
end
