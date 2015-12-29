class Users::RegistrationsController < Devise::RegistrationsController
respond_to :js, :html
skip_before_filter :check_user_status, :check_profile
# before_filter :configure_sign_up_params, only: [:create]
# before_filter :configure_account_update_params, only: [:update]

  def create
    resource = User.new(user_params)
    resource.skip_confirmation!
    if resource.save
      user = User.find resource.id
      token = user.generate_account_confirmation_token
      user.confirmation_token = token
      user.confirmation_sent_at = DateTime.current
      user.save
      user.reload
      UserMailer.account_token_with_instructions(user, token).deliver_now
      sign_in(user, bypass: true)
    end
    @errors = resource.errors.full_messages
    respond_to :js
  end

  def destroy
    # resource.destroy
    resource.update(inactive: true)
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    set_flash_message :notice, :destroyed if is_flashing_format?
    yield resource if block_given?
    respond_with_navigational(resource){ redirect_to after_sign_out_path_for(resource_name) }
  end

  private
  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
