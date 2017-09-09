class ShowcaseBroadcastJob < ApplicationJob
  # include Devise::Test::ControllerHelpers
  queue_as :default
  rescue_from(StandardError) do |e|
    logger.error "*********************************"
    logger.error e.message
    logger.error "*********************************"
    e.backtrace.each { |line| logger.error line }
  end

  def perform(showcase_id, user_ids)
  	@showcase = Showcase.find(showcase_id)
  	user_ids.each do |user_id|
  		@user = User.find(user_id)
  	  ActionCable.server.broadcast "user_#{user_id}",  showcase_content: render_showcase_partial(@showcase, @user)
  	end
  end

  private

  def render_showcase_partial(showcase, user)
    renderer = ApplicationController.renderer.new
    renderer.render(partial: 'home/showcases', locals: {showcases:  Array(showcase) , feed: "yes", current_user: user, hide_on_load_class: "hidden" })
  end
end
