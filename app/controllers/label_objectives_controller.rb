class LabelObjectivesController < ApplicationController
  before_action :set_label_objective, only: [:show, :edit, :update, :destroy]

  # GET /label_objectives
  # GET /label_objectives.json
  def index
    @label_objectives = LabelObjective.all
  end

  # GET /label_objectives/1
  # GET /label_objectives/1.json
  def show
  end

  # GET /label_objectives/new
  def new
    @label_objective = LabelObjective.new
  end

  # GET /label_objectives/1/edit
  def edit
  end

  # POST /label_objectives
  # POST /label_objectives.json
  def create
    @label_objective = LabelObjective.new(label_objective_params)

    respond_to do |format|
      if @label_objective.save
        format.html { redirect_to @label_objective, notice: 'Label objective was successfully created.' }
        format.json { render :show, status: :created, location: @label_objective }
      else
        format.html { render :new }
        format.json { render json: @label_objective.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /label_objectives/1
  # PATCH/PUT /label_objectives/1.json
  def update
    respond_to do |format|
      if @label_objective.update(label_objective_params)
        format.html { redirect_to @label_objective, notice: 'Label objective was successfully updated.' }
        format.json { render :show, status: :ok, location: @label_objective }
      else
        format.html { render :edit }
        format.json { render json: @label_objective.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /label_objectives/1
  # DELETE /label_objectives/1.json
  def destroy
    @label_objective.destroy
    respond_to do |format|
      format.html { redirect_to label_objectives_url, notice: 'Label objective was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_label_objective
      @label_objective = LabelObjective.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def label_objective_params
      params.fetch(:label_objective, {})
    end
end
