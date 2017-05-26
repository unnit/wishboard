class CommenterNotification < ApplicationRecord
  belongs_to :user
  belongs_to :comment
  belongs_to :showcase
end
