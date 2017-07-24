class AdminController < ApplicationController
  before_filter :is_admin

  def index
    @users = User.all.order('created_at DESC')
  end

  private

  def is_admin
    redirect_to(:root, flash: { notice: "Page not found" }) unless ENV['ADMIN_ID'].include? current_user.id.to_s
  end
end
