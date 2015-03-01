class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  http_basic_authenticate_with name: ENV['USERNAME'], password: ENV['PASS'], only: [:new, :create]
  skip_before_filter :require_login, only: [:new, :create]
  # GET /users
  # GET /users.json
  def index
    redirect_to edit_user_path(current_user)
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
    @nation = @user.build_nation
    @nation.user_id = @user.id
  end

  # GET /users/1/edit
  def edit
    @nation = Nation.find_by user_id: current_user.id
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to login_path, notice: 'User was successfully created!'
    else
      render :new
      flash[:error] = @user.errors
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    if @user.update(user_params)
      redirect_to nations_path, notice: 'User was successfully updated!'
    else
      render :edit
      flash[:error] = @user.errors
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, nation_attributes: [:id, :name, :url, :client_uid, :secret_key, :user_id])
    end

end
