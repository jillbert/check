class UserMailer < ActionMailer::Base
  default from: "check@cstreet.ca"
  layout 'user_mailer'

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.activation_needed_email.subject
  #
  def activation_needed_email(user)
    @user = user
    @url  = "https://checkv2.herokuapp.com/users/#{user.activation_token}/activate"
    mail(:to => user.email,
         :subject => "Welcome to Check! Please activate your account")
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.activation_success_email.subject
  #
  def activation_success_email(user)
    @user = user
    @url  = "https://checkv2.herokuapp.com/login"
    mail(:to => user.email,
         :subject => "Your Check account is now activated")
  end

  def reset_password_email(user)
    @user = User.find user.id
    @url  = "https://checkv2.herokuapp.com/password_resets/#{@user.reset_password_token}/edit"
    mail(:to => user.email,
         :subject => "Your password has been reset")
  end

end
