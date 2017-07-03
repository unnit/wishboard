class GlobalChannel < ApplicationCable::Channel
  def subscribed
  	stream_from "global_channel_#{params[:user_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
