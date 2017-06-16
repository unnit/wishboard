class MainCategory < ApplicationRecord
  has_many :chat_rooms
  has_many :sub_categories
end
