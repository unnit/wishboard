class ChatRoom < ApplicationRecord
  searchkick autocomplete: ['name']
  belongs_to :user
  belongs_to :main_category
  belongs_to :sub_category
  has_many :chat_messages, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  # has_many :online_members, -> {where(memberships: {online: true}) }, through: :memberships, source: :user

  CHAT_ROOM_TYPES = [[0, "Public"], [1, "Private"]]

  validates :name, presence: true, length: { maximum: 150 }
  #validates :wish_prefix, inclusion: {in: Showcase::WISH_PREFIX_VALUES, message: "not an accepted value."}, presence: true
  validates :main_category_id, inclusion: {in: MainCategory.all.map(&:id), message: "not an accepted value"}, presence: true
  validates :sub_category_id, inclusion: {in: SubCategory.all.map(&:id), message: "not an accepted value"}, presence: true
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

  def online_count
    memberships.where(online: true).count
  end

  def unread_messages_count(user)
    return self.chat_messages.where("chat_messages.created_at > ? and chat_messages.user_id != ?", user.get_membership(self).try(:last_seen), user.id).count
  end

  def chat_room_present
    unless ChatRoom.where("lower(name) like ? and main_category_id = ? and sub_category_id = ?", self.name.downcase, self.main_category_id, self.sub_category_id).blank?
      errors.add(:base, "Chatroom already present.")
    end
  end
end
