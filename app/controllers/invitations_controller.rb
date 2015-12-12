class InvitationsController < ApplicationController
  before_filter :authenticate_user!
  def send_email
    begin
      UserMailer.invite(current_user, params[:message], params[:emails]).deliver_now
      flash[:success] = "invitations sent successfully"
    rescue Exception => e
      flash[:danger] = e.message
    end
    redirect_to invitations_path
  end
end
