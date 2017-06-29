class AdminController < ApplicationController
  before_filter :is_admin

  def index
    redirect_to rsvps_path unless current_user.id == ENV['ADMIN_ID'].to_i
    @users = User.all.order('created_at DESC')
  end

  private

  def is_admin
    redirect_to(:root, flash: { error: "Sorry, you don't have access to this information" }) if current_user.id != ENV['ADMIN_ID'].to_i
  end
end
