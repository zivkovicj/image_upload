class ObjectiveUsersController < ApplicationController
  before_action :set_objective_user, only: [:show, :edit, :update, :destroy]

  # GET /objective_users
  # GET /objective_users.json
  def index
    @objective_users = ObjectiveUser.all
  end

  # GET /objective_users/1
  # GET /objective_users/1.json
  def show
  end

  # GET /objective_users/new
  def new
    @objective_user = ObjectiveUser.new
  end

  # GET /objective_users/1/edit
  def edit
  end

  # POST /objective_users
  # POST /objective_users.json
  def create
    @objective_user = ObjectiveUser.new(objective_user_params)

    respond_to do |format|
      if @objective_user.save
        format.html { redirect_to @objective_user, notice: 'Objective user was successfully created.' }
        format.json { render :show, status: :created, location: @objective_user }
      else
        format.html { render :new }
        format.json { render json: @objective_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /objective_users/1
  # PATCH/PUT /objective_users/1.json
  def update
    respond_to do |format|
      if @objective_user.update(objective_user_params)
        format.html { redirect_to @objective_user, notice: 'Objective user was successfully updated.' }
        format.json { render :show, status: :ok, location: @objective_user }
      else
        format.html { render :edit }
        format.json { render json: @objective_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /objective_users/1
  # DELETE /objective_users/1.json
  def destroy
    @objective_user.destroy
    respond_to do |format|
      format.html { redirect_to objective_users_url, notice: 'Objective user was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_objective_user
      @objective_user = ObjectiveUser.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def objective_user_params
      params.fetch(:objective_user, {})
    end
end
