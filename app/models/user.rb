class User < ActiveRecord::Base
  authenticates_with_sorcery!

  has_one :nation
  accepts_nested_attributes_for :nation
  
  validates :password, :presence => true, :confirmation => true, :on => :update
  validates :password_confirmation, :presence => true, :confirmation => true, :on => :update

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
