class ShowcaseNotification < ApplicationRecord
  belongs_to :showcase
  belongs_to :user
end
