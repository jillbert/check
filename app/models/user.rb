class User < ActiveRecord::Base
  authenticates_with_sorcery!

  has_one :nation
  accepts_nested_attributes_for :nation
  
  validates :password, length: { minimum: 3 }
  validates :password, confirmation: true
  validates :password_confirmation, presence: true

  validates :email, uniqueness: true
  
end
