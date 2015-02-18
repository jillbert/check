class Nation < ActiveRecord::Base

  has_many :credentials

  has_many :events
  has_many :rsvps
  

  def client
    @client ||= OAuth2::Client.new(client_uid, secret_key, :site => url)
  end
end
