class CommenterNotification < ApplicationRecord
  belongs_to :user
  belongs_to :comment
  belongs_to :showcase
  after_create_commit {NotificationBroadcastJob.perform_later(self.user)}
end
