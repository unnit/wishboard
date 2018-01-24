class InvitationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_social_layout
  def send_email
    begin
      if params[:emails].split(",").count < 70
        UserMailer.invite(current_user, params[:message], params[:emails]).deliver_now unless current_user.id == 3068
      end
      flash[:success] = "Invitations sent successfully"
    rescue Exception => e
      flash[:danger] = e.message
    end
    if params[:intro] == "yes"
      redirect_to root_path(welcome: "tour")
    else
      redirect_to root_path
    end
  end
end
