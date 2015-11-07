class AdminController < ApplicationController
  before_filter :authenticate_user!
  before_filter :require_admin!
  layout "admin"
  def require_admin!
    unless current_user && current_user.admin?
      flash[:danger] = "Invalid url"
      redirect_to root_path
    end
  end
end