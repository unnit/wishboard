class ChatRoom < ApplicationRecord
  searchkick autocomplete: ['name']
  belongs_to :user
  has_many :chat_messages, dependent: :destroy
  has_many :chat_users, -> { distinct }, through: :chat_messages, source: :user

  CHAT_ROOM_TYPES = [[0, "Public"], [1, "Private"]]

  validates :name, presence: true, length: { maximum: 150 }
  validates :wish_prefix, inclusion: {in: Showcase::WISH_PREFIX_VALUES, message: "not an accepted value."}, presence: true
  validate :chat_room_present

  HUMANIZED_ATTRIBUTES = {
    wish_prefix: "Wish Category"
  }
  def self.human_attribute_name(attr, options = {})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  scope :public_rooms, -> {where room_type: CHAT_ROOM_TYPES[0][0]}

  def public_chat?
    room_type == CHAT_ROOM_TYPES[0][0]
  end

  def private_chat?
    room_type == CHAT_ROOM_TYPES[1][0]
  end

  def chat_room_present
    unless ChatRoom.where("lower(name) like ? and wish_prefix = ?", self.name.downcase, self.wish_prefix).blank?
      errors.add(:base, "Chatroom already present.")
    end
  end
end
