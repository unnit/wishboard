class Admin::UsersController < AdminController
  before_action :set_user, only: [:update, :lock, :unlock]

  def index
    @users = User.search(params[:term]).page(params[:page]).per(40)
  end

  def update
    flash[:success] = 'User was successfully updated.' if @user.update(user_params)
    respond_to :js
  end

  def lock
    @user.lock_access!({ send_instructions: false })
    respond_to :js
  end

  def unlock
    @user.unlock_access!
    render "lock.js"
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:email, :role)
    end
end
