class Nation < ActiveRecord::Base

  has_many :credentials

  has_many :events
  has_many :rsvps
  

  def client()
    @client ||= OAuth2::Client.new(ENV['CLIENT_ID'], ENV['SECRET_KEY'], :site => url)
  end
end
