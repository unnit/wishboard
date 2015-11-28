class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profile, only: [:my_profile, :update]
  skip_before_filter :check_profile, only: [:update]

  def update
    if current_user.address
      @address = current_user.address
    else
      @address = Address.new
      @address.user = current_user
      @address.first_name = params[:profile][:first_name]
      @address.last_name = params[:profile][:last_name]
      @address.email = current_user.email
      @address.mobile = params[:profile][:phone]
    end
    @address.address1 = params[:address][:address1]
    @address.address2 = params[:address][:address2]
    @address.city = params[:address][:city]
    @address.zip = params[:address][:zip]
    @address.state = params[:address][:state]
    if @profile.update(profile_params)
      @address.save
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
      params.require(:profile).permit(:user_id, :first_name, :last_name, :image, :open_time, :close_time, :phone, :about, :update_emails, :newsletters, avail_days: [], email_notification: [])
    end
end
