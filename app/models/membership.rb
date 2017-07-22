class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :chat_room
  #after_update_commit {AppearanceBroadcastJob.perform_later self}
  after_update_commit :online_count_broadcast, if: proc { |record|
    record.previous_changes.key?(:online) &&
      record.previous_changes[:online].first != record.previous_changes[:online].last
  }
  after_update_commit :chat_messages_count_broadcast, if: proc { |record|
    record.previous_changes.key?(:last_seen) &&
      record.previous_changes[:last_seen].first != record.previous_changes[:last_seen].last
  }

  private

  def online_count_broadcast
    AppearanceBroadcastJob.perform_later self
  end

  def chat_messages_count_broadcast
    MessageCountJob.perform_later self
  end

end
