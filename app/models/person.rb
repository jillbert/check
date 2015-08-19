class Person < ActiveRecord::Base

  belongs_to :rsvp

  def full_name
    return self.first_name + " " + self.last_name
  end
  # extend ActiveModel::Naming
  # include ActiveModel::Conversion

  # attr_accessor :email, :first_name, :last_name
  # def self.from_hash(hash)
  #   address_hash = hash["primary_address"]

  #   if hash["id"]
  #     new.tap do |person|
  #       person.id = hash.fetch("id")
  #       person.email = hash.fetch("email")
  #       person.first_name = hash.fetch("first_name")
  #       person.last_name = hash.fetch("last_name")

  #       if address_hash
  #         person.address1 = address_hash.fetch("address1")
  #         person.city = address_hash.fetch("city")
  #         person.state = address_hash.fetch("state")
  #         person.country = address_hash.fetch("country_code")
  #         person.zip = address_hash.fetch("zip")
  #       end

  #       person.mobile = hash.fetch("mobile")
  #       person.phone = hash.fetch("phone")
  #     end
    
  #   else

  #     new.tap do |person|
  #       person.email = hash.fetch("email")
  #       person.first_name = hash.fetch("first_name")
  #       person.last_name = hash.fetch("last_name")
  #       person.mobile = hash.fetch("mobile")
  #     end

  #   end
  # end

  # def name
  #   [first_name, last_name].compact.join(" ")
  # end

  # def to_model
  #   self
  # end

  # def to_param
  #   id
  # end

  # def persisted?
  #   id.present?
  # end
end
