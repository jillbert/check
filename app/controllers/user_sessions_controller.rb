class UserSessionsController < ApplicationController
  skip_before_filter :require_login, except: [:destroy]
  
  def new
    @user = User.new
  end

  def create
    if @user = login(params[:email], params[:password])
      nation = Nation.where(user_id: @user.id).first
      set_current_nation(nation.id)
      credential = Credential.where(nation_id: nation.id).first
      set_current_credential(credential.id)
      redirect_back_or_to(:root, notice: 'Login successful')
    else
      flash.now[:alert] = 'Login failed'
      render action: 'new'
    end
  end

  def destroy
    logout
    destroy_currents
    redirect_to(:root, notice: 'Logged out!')
  end


  private

  def set_current_nation(id)
    session[:current_nation] = id
  end

  def set_current_credential(id)
    session[:credential_id] = id
  end

  def destroy_currents
    session[:current_nation] = nil
    session[:credential_id] = nil

  end

end