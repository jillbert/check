class OauthController < ApplicationController
  def callback
    set_current_nation(params[:state])
    credential = current_nation.credentials.create
    credential.request_access_token!(params[:code], callback_url)
    session[:credential_id] = credential.id
    # Resque.enqueue(ImportNation, current_nation.id.to_s)
    flash[:success] = 'Nation authenticated'
    redirect_to nations_path
  end

  def authorize
    credential = Credential.find_by nation_id: params[:nation_id]
    if credential.nil?
      set_current_nation(params[:nation_id])

      redirect_to client.auth_code.authorize_url(
        redirect_uri: callback_url,
        state: current_nation.id
      )
    else
      flash[:alert] = 'Nation is already authenticated.'
      redirect_to landing_path
    end
  end

  # def deauthorize
  #   deauthorize!
  #   redirect_to root_path
  # end

  private

  def client
    current_nation.client
  end

  def set_current_nation(id)
    session[:current_nation] = id
  end

  def current_nation
    @current_nation ||= Nation.where(id: session[:current_nation]).first
  end
end
