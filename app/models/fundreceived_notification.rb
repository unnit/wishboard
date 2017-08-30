class FundreceivedNotification < ApplicationRecord
	belongs_to :cocotransfer, dependent: :destroy
	belongs_to :user
	after_create_commit {NotificationBroadcastJob.perform_later(self.user)}
	after_create_commit :deliver_firebase_notification

	def notification_image_url
		if self.cocotransfer.is_anonymous?
		  return ""
		else
			return self.cocotransfer.fullfillment_contributer ? self.cocotransfer.fullfillment_contributer.profile_image_url : ""
		end
	end

	def notification_url
	  Rails.application.routes.url_helpers.showcase_url(self.cocotransfer.showcase, :host => "#{GLOBAL_VARIABLES[:root_url]}")
	end

	def notification_title
	  self.cocotransfer.showcase.user.name
	end

	def notification_text
	  "#{self.cocotransfer.display_donor_name} gifted you fresh funds for wish" + self.cocotransfer.showcase.truncated_title
	end

	def deliver_firebase_notification
	  FirebasenotificationBroadcastJob.perform_later(self.notification_title, self.notification_text, self.notification_url, self.notification_image_url,  self.user.id)
	end
end
