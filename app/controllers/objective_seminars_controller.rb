class ObjectiveSeminarsController < ApplicationController
  before_action :set_objective_seminar, only: [:show, :edit, :update, :destroy]

  # GET /objective_seminars
  # GET /objective_seminars.json
  def index
    @objective_seminars = ObjectiveSeminar.all
  end

  # GET /objective_seminars/1
  # GET /objective_seminars/1.json
  def show
  end

  # GET /objective_seminars/new
  def new
    @objective_seminar = ObjectiveSeminar.new
  end

  # GET /objective_seminars/1/edit
  def edit
  end

  # POST /objective_seminars
  # POST /objective_seminars.json
  def create
    @objective_seminar = ObjectiveSeminar.new(objective_seminar_params)

    respond_to do |format|
      if @objective_seminar.save
        format.html { redirect_to @objective_seminar, notice: 'Objective seminar was successfully created.' }
        format.json { render :show, status: :created, location: @objective_seminar }
      else
        format.html { render :new }
        format.json { render json: @objective_seminar.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /objective_seminars/1
  # PATCH/PUT /objective_seminars/1.json
  def update
    respond_to do |format|
      if @objective_seminar.update(objective_seminar_params)
        format.html { redirect_to @objective_seminar, notice: 'Objective seminar was successfully updated.' }
        format.json { render :show, status: :ok, location: @objective_seminar }
      else
        format.html { render :edit }
        format.json { render json: @objective_seminar.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /objective_seminars/1
  # DELETE /objective_seminars/1.json
  def destroy
    @objective_seminar.destroy
    respond_to do |format|
      format.html { redirect_to objective_seminars_url, notice: 'Objective seminar was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_objective_seminar
      @objective_seminar = ObjectiveSeminar.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def objective_seminar_params
      params.fetch(:objective_seminar, {})
    end
end
