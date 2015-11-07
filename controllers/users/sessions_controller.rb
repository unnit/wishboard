class Users::SessionsController < Devise::SessionsController
# before_filter :configure_sign_in_params, only: [:create]
  skip_before_filter :check_profile
  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate!(:scope => resource_name, :recall => "users/sessions#login")
    respond_to :js
  end

  def login
    sign_in(resource.class.name.underscore.to_sym, resource)
    flash[:notice] = "Signed in successfully." if current_user
    render "create.js"
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
