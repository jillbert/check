class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :require_login

  delegate :access_token, :to => :credential
  
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
    @nations = Nation.find_by user_id: current_user.id
    if !Credential.find_by nation_id: @nations.id
      redirect_to nations_path
      flash[:error] = "Please authenticate."
    end
  end

  def credential
    @credential ||= Credential.find_by_id(session[:credential_id])
  end

  def check_credential
    begin 
      response = token.get("/api/v1/people/me", :headers => standard_headers)
    rescue => ex
      cred = Credential.find_by_id(session[:credential_id])
      cred.destroy if cred
      @credential = nil
      redirect_to authorize_path(nation_id: current_user.nation.id)
    else
      @credential ||= Credential.find_by_id(session[:credential_id])
    end
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

  private
  
  def not_authenticated
    redirect_to login_path, alert: "Please login first"
  end

  def credential_params
    params.require(:credential).permit(:nation, :token, :refresh_token, :expires_at)
  end
end
