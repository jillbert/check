class UserSessionsController < ApplicationController
  skip_before_filter :require_login, except: [:destroy]
  
  def new
    if logged_in?
      check_credential
      if @credential
        redirect_back_or_to(choose_site_path)
      end
    else
      @user = User.new
    end
  end

  def create
    if @user = login(params[:email], params[:password])
      nation = Nation.where(user_id: @user.id).first
      credential = Credential.find_by nation_id: nation.id
      set_current_nation(nation.id)
      set_current_credential(credential.id)
      # credential = Credential.where(nation_id: nation.id).first
      # if credential
      #   set_current_credential(credential.id)
      #   redirect_back_or_to(choose_site_path, notice: 'Login successful')
      # else
      #   redirect_to :controller => 'nations', :action => 'index'
      # end
      check_credential
      if @credential
        redirect_back_or_to(choose_site_path, notice: 'Login successful')
      end

    else
      flash.now[:alert] = 'Login failed'
      render action: 'new'
    end
  end

  def destroy
    logout
    destroy_currents
    redirect_to(login_path, notice: 'Logged out!')
  end


  private

  def destroy_currents
    session[:current_nation] = nil
    session[:current_event] = nil
    session[:credential_id] = nil

  end

end
