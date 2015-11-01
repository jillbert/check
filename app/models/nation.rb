class Nation < ActiveRecord::Base

  has_many :credentials

  has_many :events
  has_many :people
  has_many :rsvps, through: :events
  
  CLIENT_UID = "2f680c418d315c7b51615ac9209f6dcef65231f60b806283dab6f93e0d229c69"
  SECRET_KEY = "c879330a0357de980faf4a8c9cefbc301b6c015f7a1befff9996449525292b47"

  def client()

    @client ||= OAuth2::Client.new(self.client_uid = CLIENT_UID, self.secret_key = SECRET_KEY, :site => url)
  end
end
