class AchievedNotification < ApplicationRecord
  belongs_to :showcase
  belongs_to :user
end
