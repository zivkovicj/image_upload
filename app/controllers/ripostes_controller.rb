class RipostesController < ApplicationController
  before_action :set_riposte, only: [:show, :edit, :update, :destroy]

  # GET /ripostes
  # GET /ripostes.json
  def index
    @ripostes = Riposte.all
  end

  # GET /ripostes/1
  # GET /ripostes/1.json
  def show
  end

  # GET /ripostes/new
  def new
    @riposte = Riposte.new
  end

  # GET /ripostes/1/edit
  def edit
  end

  # POST /ripostes
  # POST /ripostes.json
  def create
    @riposte = Riposte.new(riposte_params)

    respond_to do |format|
      if @riposte.save
        format.html { redirect_to @riposte, notice: 'Riposte was successfully created.' }
        format.json { render :show, status: :created, location: @riposte }
      else
        format.html { render :new }
        format.json { render json: @riposte.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ripostes/1
  # PATCH/PUT /ripostes/1.json
  def update
    respond_to do |format|
      if @riposte.update(riposte_params)
        format.html { redirect_to @riposte, notice: 'Riposte was successfully updated.' }
        format.json { render :show, status: :ok, location: @riposte }
      else
        format.html { render :edit }
        format.json { render json: @riposte.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ripostes/1
  # DELETE /ripostes/1.json
  def destroy
    @riposte.destroy
    respond_to do |format|
      format.html { redirect_to ripostes_url, notice: 'Riposte was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_riposte
      @riposte = Riposte.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def riposte_params
      params.fetch(:riposte, {})
    end
end
