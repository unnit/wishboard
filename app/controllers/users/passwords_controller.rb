class Users::PasswordsController < Devise::PasswordsController
  skip_before_action :check_user_status, :check_profile, :check_interests, raise: false
  before_action :set_social_layout, only: [:new, :edit, :update]
  # GET /resource/password/new
  def new

  end

  # POST /resource/password
  def create
      @user = User.find_by_email params[:user][:email]
      unless @user.blank?
        reset_token = @user.generate_reset_password_token
        @user.reset_password_token = reset_token
        @user.reset_password_sent_at = DateTime.current
        @user.save
        UserMailer.reset_password_token_with_instructions(@user, reset_token).deliver_now
        flash[:notice] = "A mail has been sent to your email id with reset password instructions."
        redirect_to root_path
      else
        flash[:alert] = "Sorry, Email ID is invalid. Please try again"
        render :new
        return
      end
  end

  # GET /resource/password/edit?reset_password_token=abcdef
  def edit
    @user = User.find_by_id params[:id]
    unless @user.blank?
      unless @user.reset_password_token == params[:reset_password_token] && DateTime.current < (@user.reset_password_sent_at + 6.hours)
        flash[:alert] = "Sorry, this link has expired."
        redirect_to root_path
        return
      end
    else
      redirect_to root_path
      return
    end
  end

  # PUT /resource/password
  def update
    @user = User.find_by_id params[:user][:id]
    logger.info params[:reset_password_token]
    unless @user.blank?
      if @user.reset_password_token == params[:user][:reset_password_token] && DateTime.current < (@user.reset_password_sent_at + 6.hours)
        if @user.update_attributes(password_params)
          @user.update_column :reset_password_token, nil
          flash[:notice] = "Congratulations, You have successfully updated your password"
          redirect_to root_path
          return
        else
          flash[:alert] = @user.errors.full_messages.join(",")
          render :edit
          return
        end
      else
        flash[:alert] = "Reset password token mismatch."
        redirect_to root_path
        return
      end
    else
      redirect_to root_path
      return
    end
  end

  # protected

  def after_resetting_password_path_for(resource)

  end

  # The path used after sending reset password instructions
  def after_sending_reset_password_instructions_path_for(resource_name)
  #   super(resource_name)
  end

  private
  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

end
