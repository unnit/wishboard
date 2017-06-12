class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :chat_room
  after_update_commit {AppearanceBroadcastJob.perform_later self}
end
