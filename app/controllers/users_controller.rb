class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update destroy]
  before_action :same_user, only: %i[show edit update destroy]
  http_basic_authenticate_with name: ENV['USERNAME'], password: ENV['PASSWORD'], only: %i[new create index show]
  skip_before_filter :require_login, only: %i[new create activate confirm]
  # GET /users
  # GET /users.json
  def index
    redirect_to edit_user_path(current_user)
  end

  # GET /users/1
  # GET /users/1.json
  def show; end

  # GET /users/new
  def new
    @user = User.new
    @nation = @user.build_nation
    @user.nation = @nation
  end

  # GET /users/1/edit
  def edit
    @page = 'settings'
    @nation = @user.nation
    render layout: false
  end

  def new_password
    @user = User.find(params[:id])
  end

  def change_password
    if @user.update(user_params)
      redirect_to nations_path, notice: 'Password was successfully updated!'
    else
      render :new_password
      flash[:error] = @user.errors
    end
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    @user.skip_validation = true

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
      @user.update_attributes(color: nil) if @user.color.nil? || @user.color.empty?
      @user.update_attributes(logo: nil) if @user.logo.nil? || @user.logo.empty?
      redirect_to admin_path, notice: 'User was successfully updated!'
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

  def activate
    if (@user = User.load_from_activation_token(params[:id]))
      @token = params[:id]
    else
      not_authenticated
    end
  end

  def confirm
    @token = params[:activation_token]
    if @user = User.load_from_activation_token(@token)
      if @user.update_attributes(user_params)
        @user.activate!
        redirect_to login_url, notice: 'Your account is now activated.'
      else
        render :activate
      end
    else
      not_authenticated
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  def same_user
    redirect_to root_path if current_user != @user && current_user.id != 1
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:email, :username, :password, :password_confirmation, :active, :color, :logo, :nation_id, :nation_attributes => [:id, :name, :url, :client_uid, :secret_key])
  end
end
