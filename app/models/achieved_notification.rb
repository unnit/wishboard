class AchievedNotification < ApplicationRecord
  belongs_to :showcase
  belongs_to :user
  after_create_commit {NotificationBroadcastJob.perform_later(self.user)}
end
