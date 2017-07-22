class CostlyJob < ApplicationJob
  queue_as :default

  def perform(user, showcase)
    user.followers.each do |follower|
      showcase.achieved_notifications.where(user_id: follower.id).first_or_create.update_columns(active: true, updated_at: Time.now.utc)
    end
  end
end
