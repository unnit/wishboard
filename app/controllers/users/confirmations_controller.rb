class Users::ConfirmationsController < Devise::ConfirmationsController

  skip_before_filter :check_user_status, only: [:new, :show]

  # GET /resource/confirmation/new
  def new
    if current_user
      if current_user.inactive
        confirmation_token = current_user.generate_account_confirmation_token
        current_user.confirmation_token = confirmation_token
        current_user.confirmation_sent_at = DateTime.current
        current_user.save
        UserMailer.account_token_with_instructions(current_user, confirmation_token).deliver_now
        flash[:notice] = "A mail has been resent to your mail now. If you haven't received instructions, Please <a href='/users/confirmation/new' >Click here</a> to resend instructions".html_safe
        redirect_to root_path
      else
        flash[:notice] = "We have already verified your account. Enjoy Cocociti. Go Coco!!"
        redirect_to root_path
        return
      end
    else
      redirect_to root_path
      return
    end
  end

  # POST /resource/confirmation
  #def create

  #end

  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    unless current_user
      user = User.find_by_id params[:id]
    else
      user = current_user
    end
    unless user.blank?
      if user.inactive
        if user.confirmation_token == params[:confirmation_token] && user.id == params[:id].to_i
          user.inactive = false
          user.confirmed_at = DateTime.current
          user.confirmation_token = ""
          user.save
          unless current_user
            sign_in(user, bypass: true)
          end
          flash[:notice] = "Your account has been verified successfully. Experience Cocociti. Go Coco!!<br>Please fill in your profile before you continue so that we can ease your Cocociti journey.".html_safe
          redirect_to settings_path
          return
        else
          flash[:alert] = "Confirmation token mismatch. Please check your mail again"
          redirect_to root_path
          return
        end
      else
        flash[:notice] = "We have already verified your account. Enjoy Cocociti. Go Coco!!"
        redirect_to root_path
        return
      end
    else
      redirect_to root_path
      return
    end
  end

  # protected

  # The path used after resending confirmation instructions.
  # def after_resending_confirmation_instructions_path_for(resource_name)
  #   super(resource_name)
  # end

  # The path used after confirmation.
  # def after_confirmation_path_for(resource_name, resource)
  #   super(resource_name, resource)
  # end
end
