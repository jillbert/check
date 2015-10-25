class Person < ActiveRecord::Base

  belongs_to :rsvp

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates_format_of :first_name, :with => /\A[^0-9`!@#\$%\^&*+_=]+\z/
  validates_format_of :last_name, :with => /\A[^0-9`!@#\$%\^&*+_=]+\z/
  validates :email, :email => true
  
  def full_name
    return self.first_name + " " + self.last_name
  end

  def nbid=(val)
    write_attribute(:nbid, val.to_i)
  end

  def self.import(p, rsvp_id)
    person = Person.find_or_create_by(
      nbid: p['id'],
      rsvp_id: rsvp_id
    )

    person.update(
      first_name: p["first_name"],
      last_name: p["last_name"],
      email: p["email"],
      phone_number: p["phone"],
      pic: p["profile_image_url_ssl"]
    )

    return person

  end

  def to_person_object
    person_object = {
      :person => {
        :first_name => self.first_name,
        :last_name => self.last_name,
        :email => self.email,
      }
    }
    
    return person_object.to_json

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
