class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profile, only: [:my_profile, :update]
  skip_before_filter :check_profile, only: [:update]
  
  def update
    if @profile.update(profile_params)
      flash[:success] = 'Profile was successfully updated.'
    else
      flash[:danger] = @profile.errors.full_messages.join("<br/>")
    end
    redirect_to settings_path
  end

  private
    def set_profile
      @profile = current_user.profile || current_user.create_profile
    end

    def profile_params
      params.require(:profile).permit(:user_id, :first_name, :last_name, :image, :open_time, :close_time,
        :location, :phone, :about, :update_emails, :newsletters, avail_days: [], email_notification: [], location_attributes: [:name, :lat, :lng])
    end
end
