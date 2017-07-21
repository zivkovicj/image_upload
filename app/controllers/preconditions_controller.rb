class PreconditionsController < ApplicationController
  before_action :set_precondition, only: [:show, :edit, :update, :destroy]

  # GET /preconditions
  # GET /preconditions.json
  def index
    @preconditions = Precondition.all
  end

  # GET /preconditions/1
  # GET /preconditions/1.json
  def show
  end

  # GET /preconditions/new
  def new
    @precondition = Precondition.new
  end

  # GET /preconditions/1/edit
  def edit
  end

  # POST /preconditions
  # POST /preconditions.json
  def create
    @precondition = Precondition.new(precondition_params)

    respond_to do |format|
      if @precondition.save
        format.html { redirect_to @precondition, notice: 'Precondition was successfully created.' }
        format.json { render :show, status: :created, location: @precondition }
      else
        format.html { render :new }
        format.json { render json: @precondition.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /preconditions/1
  # PATCH/PUT /preconditions/1.json
  def update
    respond_to do |format|
      if @precondition.update(precondition_params)
        format.html { redirect_to @precondition, notice: 'Precondition was successfully updated.' }
        format.json { render :show, status: :ok, location: @precondition }
      else
        format.html { render :edit }
        format.json { render json: @precondition.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /preconditions/1
  # DELETE /preconditions/1.json
  def destroy
    @precondition.destroy
    respond_to do |format|
      format.html { redirect_to preconditions_url, notice: 'Precondition was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_precondition
      @precondition = Precondition.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def precondition_params
      params.fetch(:precondition, {})
    end
end
