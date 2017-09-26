class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :require_login

  delegate :access_token, to: :credential

  def authenticate_admin_user!
    redirect_to root_path unless ENV['ADMIN_ID'].split(",").include?(current_user.id.to_s)
  end

  def current_admin_user
    current_user
  end

  private

  def deauthorize!
    credential.destroy if credential
    session[:current_nation] = nil
    session[:credential_id] = nil
  end

  def token
    credential.access_token
  end

  def has_credential?
    nation = current_user.nation
    credential = Credential.find_by nation_id: nation.id
    unless credential
      redirect_to authorize_path(nation_id: current_user.nation.id)
      flash[:error] = 'Please authenticate.'
    end
  end

  def credential
    @credential ||= Credential.find_by_id(session[:credential_id])
  end

  def check_credential
    response = token.get('/api/v1/people/me', headers: standard_headers)
  rescue => ex
    cred = Credential.find_by_id(session[:credential_id])
    cred.destroy if cred
    @credential = nil
    redirect_to authorize_path(nation_id: current_user.nation.id)
  else
    @credential ||= Credential.find_by_id(session[:credential_id])
  end

  def token_for_transactions(credential)
    credential.access_token
  end

  helper_method :nation

  def nation
    credential.nation
  end

  def standard_headers
    { 'Accept' => 'application/json', 'Content-Type' => 'application/json' }
  end

  def set_current_nation(id)
    session[:current_nation] = id
  end

  def set_current_credential(id)
    session[:credential_id] = id
  end

  private

  def not_authenticated
    redirect_to login_path, alert: 'Please login first'
  end

  def credential_params
    params.require(:credential).permit(:nation, :token, :refresh_token, :expires_at)
  end
end
