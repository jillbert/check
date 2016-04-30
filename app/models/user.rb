class User < ActiveRecord::Base
  authenticates_with_sorcery!

  has_one :nation
  accepts_nested_attributes_for :nation
  
  validates :password, length: { minimum: 3 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }

  validates :email, uniqueness: true

  before_create :setup_activation
  after_create :send_activation_needed_email!


  def external?
    false
  end

  def resend_activation_email!
    send_activation_needed_email!
  end
    
end
