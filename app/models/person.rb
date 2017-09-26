class Person < ActiveRecord::Base
  belongs_to :nation
  has_many :rsvps
  accepts_nested_attributes_for :rsvps

  def full_name
    if first_name && last_name
      first_name + ' ' + last_name
    elsif first_name
      first_name
    elsif last_name
      last_name
    end
  end

  def nbid=(val)
    write_attribute(:nbid, val.to_i)
  end

  def self.import(p, nation)
    person = Person.find_or_create_by(
      nbid: p['id'],
      nation_id: nation
    )
    zip = p['home_address']['zip'] if p['home_address']
    person.update(
      first_name: p['first_name'],
      last_name: p['last_name'],
      email: p['email'],
      phone_number: p['phone'],
      work_phone_number: p['work_phone_number'],
      mobile: p['mobile'],
      home_zip: zip,
      pic: p['profile_image_url_ssl']
    )
    person
  end

  def to_person_object
    person_object = {
      person: {
        first_name: first_name,
        last_name: last_name,
        email: email,
        phone: phone_number,
        work_phone_number: work_phone_number,
        mobile: mobile,
        home_address: { zip: home_zip }
      }
    }

    person_object.to_json
  end
end
