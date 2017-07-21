class SeminarUsersController < ApplicationController
  before_action :set_seminar_user, only: [:show, :edit, :update, :destroy]

  # GET /seminar_users
  # GET /seminar_users.json
  def index
    @seminar_users = SeminarUser.all
  end

  # GET /seminar_users/1
  # GET /seminar_users/1.json
  def show
  end

  # GET /seminar_users/new
  def new
    @seminar_user = SeminarUser.new
  end

  # GET /seminar_users/1/edit
  def edit
  end

  # POST /seminar_users
  # POST /seminar_users.json
  def create
    @seminar_user = SeminarUser.new(seminar_user_params)

    respond_to do |format|
      if @seminar_user.save
        format.html { redirect_to @seminar_user, notice: 'Seminar user was successfully created.' }
        format.json { render :show, status: :created, location: @seminar_user }
      else
        format.html { render :new }
        format.json { render json: @seminar_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /seminar_users/1
  # PATCH/PUT /seminar_users/1.json
  def update
    respond_to do |format|
      if @seminar_user.update(seminar_user_params)
        format.html { redirect_to @seminar_user, notice: 'Seminar user was successfully updated.' }
        format.json { render :show, status: :ok, location: @seminar_user }
      else
        format.html { render :edit }
        format.json { render json: @seminar_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /seminar_users/1
  # DELETE /seminar_users/1.json
  def destroy
    @seminar_user.destroy
    respond_to do |format|
      format.html { redirect_to seminar_users_url, notice: 'Seminar user was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_seminar_user
      @seminar_user = SeminarUser.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def seminar_user_params
      params.fetch(:seminar_user, {})
    end
end
