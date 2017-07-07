class Wow < ApplicationRecord
  belongs_to :user
  belongs_to :showcase
  after_create_commit {NotificationBroadcastJob.perform_later(self.showcase.user)}
end
