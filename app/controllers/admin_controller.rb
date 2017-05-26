class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!
  layout "admin"
  def require_admin!
    unless current_user && current_user.admin?
      flash[:danger] = "Invalid url"
      redirect_to root_path
    end
  end
end
