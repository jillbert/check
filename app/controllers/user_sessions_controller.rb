class UserSessionsController < ApplicationController
  skip_before_filter :require_login, except: [:destroy]

  def new
    if logged_in?
      check_credential
      redirect_back_or_to(landing_path) if @credential
    else
      @noheader = true
      @nofooter = true
      @user = User.new
    end
  end

  def create
    if @user = login(params[:email], params[:password])
      if @user.active
        nation = @user.nation
        credential = Credential.find_by(nation_id: nation.id) unless nation.nil?

        set_current_nation(nation.id)

        if credential
          set_current_credential(credential.id)
          redirect_back_or_to(landing_path, notice: 'Login successful')
        else
          redirect_to authorize_path(nation_id: current_user.nation.id)
        end
      else
        logout
        destroy_currents
        redirect_to(login_path, notice: 'Sorry your account has been suspended. If you think is in error, please contact support@cstreet.ca.')
      end
    else
      redirect_to(login_path, alert: 'Login failed')
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
