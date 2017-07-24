class User < ActiveRecord::Base
  authenticates_with_sorcery!

  belongs_to :nation
  accepts_nested_attributes_for :nation

  validates :password, length: { minimum: 3 }, if: -> { new_record? || changes[:crypted_password] }, unless: :skip_validation?
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }, unless: :skip_validation?
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }, unless: :skip_validation?

  validates :email, uniqueness: true

  before_create :setup_activation
  # after_create :send_activation_needed_email!

  attr_accessor :skip_validation

  def skip_validation?
    @skip_validation
  end

  def external?
    false
  end

  def resend_activation_email!
    send_activation_needed_email!
  end
end
