class FirebasenotificationBroadcastJob < ApplicationJob
	require 'firebase_service'
	queue_as :default
	rescue_from(StandardError) do |e|
		logger.error "*********************************"
		logger.error e.message
		logger.error "*********************************"
		e.backtrace.each { |line| logger.error line }
	end


	def perform(title, body,url, image, user_id)
		active_registration_tokens = FirebaseToken.where(user_id: user_id).active_tokens.pluck(:token)
		active_registration_tokens.each_slice(999) do |registration_tokens|
			FirebaseService.new.send_notification(title,body,url, image,registration_tokens)
		end
	end

end
