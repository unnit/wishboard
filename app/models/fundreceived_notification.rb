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
		if self.cocotransfer.showcase_transfer?
		  Rails.application.routes.url_helpers.showcase_url(self.cocotransfer.transferable, :host => "#{GLOBAL_VARIABLES[:root_url]}")
		else
			 Rails.application.routes.url_helpers.wallet_url(host: "#{GLOBAL_VARIABLES[:root_url]}" )
		end
	end

	def notification_path
		if self.cocotransfer.showcase_transfer?
		  Rails.application.routes.url_helpers.showcase_path(self.cocotransfer.transferable)
		else
			 Rails.application.routes.url_helpers.wallet_path
		end
	end

	def notification_title
	  self.cocotransfer.receiver.name
	end

	def notification_text
	  showcase_details_text = self.cocotransfer.showcase_transfer? ? ("for wish #{self.cocotransfer.transferable.truncated_title}") : ""
	  "#{self.cocotransfer.display_donor_name} gifted you fresh funds for wish #{showcase_details_text}"
	end

	def deliver_firebase_notification
	  FirebasenotificationBroadcastJob.perform_later(self.notification_title, self.notification_text, self.notification_url, self.notification_image_url,  self.user.id)
	end
end
