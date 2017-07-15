class ShowcaseBroadcastJob < ApplicationJob
  # include Devise::Test::ControllerHelpers
  queue_as :default
  rescue_from(StandardError) do |e|
    logger.error "*********************************"
    logger.error e.message
    logger.error "*********************************"
    e.backtrace.each { |line| logger.error line }
  end

  def perform(showcaseid, user_ids)
  	@showcase = Showcase.find(showcaseid)
  	user_ids.each do |userid|
  		@user = User.find(userid)
  	  ActionCable.server.broadcast "user_#{userid}",  showcase_content: render_showcase_partial(@showcase, @user), user_id: userid
  	end
  end

  private

  def render_showcase_partial(showcase, user)
    renderer = ApplicationController.renderer.new
    renderer_env = renderer.instance_eval { @env }
    warden = ::Warden::Proxy.new(renderer_env, ::Warden::Manager.new(Rails.application))
    renderer_env["warden"] = warden
   renderer.render(partial: 'home/showcases', locals: {showcases:  Array(showcase) , feed: "yes", current_user: user, hide_on_load_class: "hidden" })
  end
end
