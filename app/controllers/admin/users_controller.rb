class Admin::UsersController < AdminController
  before_action :set_user, only: [:update, :lock, :unlock, :update_verified]

  def admin_firebasenotifications
  end

  def send_new_firebase_notification
   @notification = { notification_title: params[:firebase_notification][:notification_title],notification_text: params[:firebase_notification][:notification_text], notification_image_url: params[:firebase_notification][:notification_image_url] }
    FirebasenotificationBroadcastJob.perform_later(@notification[:notification_title].to_s, @notification[:notification_text].to_s, @notification[:notification_url].to_s, @notification[:notification_image_url].to_s, User.all.pluck(:id))
   render json: {status: "SENDING"} and return
 end

  def index
    @users = User.admin_search(params[:term]).page(params[:page]).per(40)
  end

  def update
    flash[:success] = 'User was successfully updated.' if @user.update(user_params)
    respond_to :js
  end

  def update_verified
    @user.toggle_verify!
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

  def messages
  end

  def send_message
    nos = []
    params[:mobile].split(",").each do |no|
      if no.length < 10
        flash[:alert] = "Please check the mobile numbers."
        render :messages
        return
      end
      nos << no
    end
    nos.each do |no|
      send_mobile_sms("#{no}", params[:message])
    end
    flash[:notice] = "Message sent successfully"
    redirect_to messages_admin_users_path
  end

  def withdraws
    @withdraws = Withdraw.all.order(created_at: :desc).page(params[:withdraws]).per(30)
  end

  def update_withdraw
    withdraw = Withdraw.find params[:id]
    withdraw.status = params[:status] unless withdraw.deactivated?
    withdraw.comment = params[:comment]
    if withdraw.save
      flash[:notice] = "Updated successfully"
    else
      flash[:alert] = withdraw.errors.join.(", ")
    end
    respond_to :js
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:email, :role)
    end
end
