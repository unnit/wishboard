class Relationship < ApplicationRecord
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"
  after_create_commit {NotificationBroadcastJob.perform_later(self.followed)}
end
