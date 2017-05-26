class ChatMessage < ApplicationRecord
  belongs_to :user
  belongs_to :chat_room

  validates :content, presence: true, length: { maximum: 10000 }

  after_create_commit {ChatBroadcastJob.perform_later(self)}
end
