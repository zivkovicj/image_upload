class PicturesController < ApplicationController
  before_action :set_picture, only: [:show, :edit, :update, :destroy]
  before_action only: [:delete, :destroy] do
    correct_owner(Picture)
  end

  include LabelsList

  def new
    @picture = Picture.new
    @labels = labels_to_offer
  end

  def create
    @picture = Picture.new(picture_params)
    @picture.user = current_user
    
    if @picture.save
      flash[:success] = "New Picture Successfully Created"
      redirect_to current_user
    else
      render 'new'
    end
  end

  def index
    @pictures = Picture.all
  end

  def show
  end

  def edit
    set_picture
    @labels = labels_to_offer
  end

  def update
    @picture = Picture.find(params[:id])
    if @picture.update(picture_params)
      flash[:success] = "Picture Updated"
      redirect_to current_user
    else
      render 'edit'
    end
  end

  def destroy
    @picture = Picture.find(params[:id])
    @picture.questions.each do |quest|
      quest.update(:picture => nil)
    end
    @picture.labels.each do |lab|
      lab.pictures.delete(@picture)
    end
    if @picture.destroy
      flash[:success] = "Picture Deleted"
      redirect_to pictures_path
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_picture
      @picture = Picture.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def picture_params
      params.require(:picture).permit(:name, :image, label_ids: [])
    end
end
