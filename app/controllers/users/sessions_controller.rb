class Users::SessionsController < Devise::SessionsController
# before_action :configure_sign_in_params, only: [:create]
  skip_before_action :check_user_status, :check_profile, :check_interests, :check_username_locked, raise: false

  # GET /resource/sign_in
  def new
    redirect_to root_path
  end

  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate!(:scope => resource_name, :recall => "users/sessions#login")
    flash[:notice] = "Signed in successfully." if current_user
    if session["user_return_to"]
      #respond_with resource, location: after_sign_in_path_for(resource)
      render js: "window.location = '#{GLOBAL_VARIABLES[:root_url]}#{session.delete(:user_return_to)}'"
    else
      respond_to do |format|
        format.html { redirect_to root_path }
        format.js { respond_to :js }
        format.json { render json: { :success => true, :info => "Logged in", :data => { :auth_token => current_user.id } } }
      end
    end
  end

  def login
    sign_in(resource.class.name.underscore.to_sym, resource)
    flash[:notice] = "Signed in successfully." if current_user
    respond_to do |format|
      format.html {
        flash[:alert] = "Please enter a valid email and password."
        redirect_to root_path
      }
      format.js { render "create.js" }
    end
  end

  # DELETE /resource/sign_out
  def destroy
    @firebasetoken = FirebaseToken.where(token: params[:firebasetoken], user_id: current_user.try(:id)).update_all(active: false)
    ActionCable.server.remote_connections.where(current_user: current_user).disconnect
    super
  end

  def demo_login
    demo_user = User.find_by(email: "test@dtlabs.me")
    if demo_user
      sign_in(:user, demo_user)
      flash[:notice] = "Logged in as Dheeraj T - Demo User"
      redirect_to root_path
    else
      flash[:alert] = "Demo user not found."
      redirect_to new_session_path(resource_name)
    end
  end

  # protected

  # You can put the params you want to permit in the empty array.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.for(:sign_in) << :attribute
  # end
end
