class SettingsController < ApplicationController
  before_filter :authenticate_user!

  skip_before_filter :check_profile

  def index
    @profile = current_user.profile || current_user.create_profile
    @profile.init_availability if @profile.avail_days.blank?
    @profile.location || @profile.build_location
    @user = current_user
    @address = current_user.address unless current_user.address.blank?
  end

end
