class Profile < ActiveRecord::Base
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged
  def slug_candidates
    [
      [:first_name, :last_name],
      [:first_name, :last_name, :id]
    ]
  end
  def should_generate_new_friendly_id?
    slug.blank? || first_name_changed? || last_name_changed?
  end

  serialize :email_notification
  serialize :avail_days

  mount_uploader :image, ImageUploader
  belongs_to :user
  has_one :location, as: :locatable, dependent: :destroy
  acts_as_mappable through: :location
  accepts_nested_attributes_for :location

  validates :first_name, :last_name, :phone, :avail_days, :open_time, :close_time, presence: true, on: :update
  validates :phone, uniqueness: true, on: :update
  validates :phone, length: { is: 10 }, on: :update
  validates :phone, numericality: true, on: :update
  validates :about, length: { maximum: 1000 }, on: :update, unless: :about_entered?

  class << self
    def create_open_close_time
      Array.new((24.hours/30.minutes)) do |i|
        ["#{(Time.now.midnight + (i*30.minutes) + 0).strftime('%H:%M')} #{(Time.now.midnight + (i*30.minutes) + 0).strftime('(%I:%M %p)')}", (Time.now.midnight + (i*30.minutes) + 0).strftime("%H:%M")]
      end
    end

    def time_options
      ["00:00", "00:30", "01:00", "01:30", "02:00", "02:30", "03:00", "03:30", "04:00", "04:30", "05:00", "05:30", "06:00", "06:30",
       "07:00", "07:30", "08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "14:30",
       "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00", "18:30", "19:00", "19:30", "20:00", "20:30", "21:00", "21:30",
       "22:00", "22:30", "23:00", "23:30"]
    end
  end

  def about_entered?
    about.blank?
  end

  def avail_days_arr
    init_availability unless avail_days
    avail_days.to_a
  end

  def disabled_days
    ("0".."6").to_a - avail_days_arr
  end

  def min_h
    open_time.split(":").first.to_i
  end

  def min_m
    open_time.split(":").last.to_i
  end

  def max_h
    close_time.split(":").first.to_i
  end

  def max_m
    close_time.split(":").last.to_i
  end

  def address
    location.name if location
  end

  def name
    "#{first_name} #{last_name}"
  end

  def init_availability
    update_columns avail_days: ["1","2","3","4","5"], open_time: "08:00 AM", close_time: "5:00 PM"
  end
end
