class AchievedNotification < ActiveRecord::Base
  belongs_to :showcase
  belongs_to :user
end
