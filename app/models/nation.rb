class Nation < ActiveRecord::Base

  has_many :credentials

  def client
    @client ||= OAuth2::Client.new(client_uid, secret_key, :site => url)
  end
end
