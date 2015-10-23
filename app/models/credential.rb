class Credential < ActiveRecord::Base
  delegate :client, to: :nation
  belongs_to :nation

  def request_access_token!(code, redirect_uri)
    @access_token = client.auth_code.get_token(code, redirect_uri: redirect_uri)
    update_from_token(@access_token)
    @access_token
  end

  def access_token
    @access_token ||= build_access_token
  end

  private

  def update_from_token(token)
    update_attributes!(token: token.token)
  end

  def build_access_token
    OAuth2::AccessToken.new(client, token)
  end
end
