class InvitationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_social_layout
  def send_email
    begin
      UserMailer.invite(current_user, params[:message], params[:emails]).deliver_now
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
