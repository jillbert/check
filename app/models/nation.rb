class Nation < ActiveRecord::Base

  has_many :credentials
  has_many :events, inverse_of: :nation
  has_many :people
  has_many :rsvps, through: :events
  has_many :users

  def client()

    @client ||= OAuth2::Client.new(self.client_uid = ENV['CLIENT_UID'], self.secret_key = ENV['SECRET_KEY'], :site => url)
    # @client ||= OAuth2::Client.new(self.client_uid = ENV['CLIENT_UID'], self.secret_key = ENV['SECRET_KEY'], :site => "https://#{name}.nationbuilder.com/")

  end
end
