class FirebaseToken < ApplicationRecord
	belongs_to :user
	scope :active_tokens, -> {where(active: true)}
end
