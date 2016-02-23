class Users::SessionsController < Devise::SessionsController
# before_filter :configure_sign_in_params, only: [:create]
  skip_before_filter :check_user_status, :check_profile
  # GET /resource/sign_in
  def new
    redirect_to login_path
  end

  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate!(:scope => resource_name, :recall => "users/sessions#login")
    flash[:notice] = "Signed in successfully." if current_user
    if session["user_return_to"]
      respond_with resource, location: after_sign_in_path_for(resource)
    else
      respond_to do |format|
        format.html { redirect_to root_path }
        format.js { respond_to :js }
      end
    end
  end

  def login
    sign_in(resource.class.name.underscore.to_sym, resource)
    flash[:notice] = "Signed in successfully." if current_user
    respond_to do |format|
      format.html {
        flash[:alert] = "Please enter a valid email and password."
        redirect_to login_path
      }
      format.js { render "create.js" }
    end
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # You can put the params you want to permit in the empty array.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.for(:sign_in) << :attribute
  # end
end
