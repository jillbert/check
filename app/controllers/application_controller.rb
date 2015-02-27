class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :require_login

  delegate :access_token, :to => :credential

  # helper_method :logged_in?

  private

  def deauthorize!
    credential.destroy if credential
    session[:current_nation] = nil
    session[:credential_id] = nil
  end

  def token
    credential.access_token
  end

  # def logged_in?
  #   credential.present?
  # end

  def credential
    @credential ||= Credential.find_by_id(session[:credential_id])
  end

  def get_credential(nid)
    @credential ||= Credential.find_by nation_id: nid
    return cred.token
  end

  def token_for_transactions(credential)
    return credential.access_token
  end

  helper_method :nation
  def nation
    credential.nation
  end

  def standard_headers
    { "Accept" => "application/json", "Content-Type" => "application/json" }
  end

  def has_session_info
    if session[:current_site]
      if session[:current_event]
        true
      else
        redirect_to choose_event_path
      end
    else
      redirect_to events_path
    end
  end

  private
  
  def not_authenticated
    redirect_to login_path, alert: "Please login first"
  end

  def credential_params
    params.require(:credential).permit(:nation, :token, :refresh_token, :expires_at)
  end
end
