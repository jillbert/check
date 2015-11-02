class AdminController < ApplicationController
  before_filter :is_admin

  def index
    @users = User.all
  end

  private

  def is_admin
    redirect_to(:root, flash: { error: "Sorry, you don't have access to this information"}) if current_user.id != 2
  end
end
