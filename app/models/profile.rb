class Profile < ActiveRecord::Base
  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged
  def slug_candidates
    [:slug]
  end

  attr_accessor :business_fields_mandatory, :weekend_pricing, :hourly_pricing

  GENDER = ["male", "female", "other"]
  BUSINESS_TYPE = [["Individual", 0], ["Business", 1]]
  BUSINESS_TYPE_VALUES = [0, 1]
  MONTHS = [["Jan", 1], ["Feb", 2], ["Mar", 3], ["Apr", 4], ["May", 5], ["Jun", 6], ["Jul", 7],
   ["Aug", 8], ["Sep", 9], ["Oct", 10], ["Nov", 11], ["Dec", 12]]
  TIME_OPTIONS = ["00:00", "00:30", "01:00", "01:30", "02:00", "02:30", "03:00", "03:30", "04:00", "04:30", "05:00", "05:30", "06:00", "06:30",
   "07:00", "07:30", "08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "14:30",
   "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00", "18:30", "19:00", "19:30", "20:00", "20:30", "21:00", "21:30",
   "22:00", "22:30", "23:00", "23:30"]

  serialize :email_notification
  serialize :avail_days
  serialize :weekend_days

  mount_uploader :image, ImageUploader
  belongs_to :user
  has_one :location, as: :locatable, dependent: :destroy
  acts_as_mappable through: :location
  accepts_nested_attributes_for :location

  validates :first_name, :last_name, :slug, presence: true
  validates :slug, uniqueness: true
  validates :first_name, :last_name, length: { maximum: 100, message: "should be between 100 characters." }
  validates :slug, length: { minimum: 6, maximum: 30, message: "should be between 6 and 30 characters." }
  validates :slug, format: { with: /\A[a-zA-Z0-9\_\-]*\z/, message: "only allows alphabets, numbers, underscore and hyphen" }

  validates :gender, inclusion: { in: Profile::GENDER, message: "should not be blank" }, unless: :gender_blank?, on: :update
  validates_date :date_of_birth, :before => lambda { 18.years.ago },
                               :before_message => ": Must be at least 18 years old", on: :update
  validates :phone, uniqueness: true, on: :update, unless: :phone_blank?
  validates :phone, length: { is: 10, message: "should not be greater than 10 digits." }, on: :update, unless: :phone_blank?
  validates :phone, numericality: true, on: :update, unless: :phone_blank?
  validates :about, length: { maximum: 250 }, on: :update, unless: :about_blank?

  validates :twitter, :facebook, :instagram, :linkedin, :google_plus, :website, :other_url, length: { maximum: 220 }, on: :update

  validates :avail_days, presence: true, unless: :business_fields_mandatory_blank?
  validates :weekend_days, presence: true, unless: :weekend_pricing_blank?

  validates :business_type, inclusion: { in: Profile::BUSINESS_TYPE_VALUES, message: "should not be blank" }, unless: :business_fields_mandatory_blank?
  validates :open_time, inclusion: { in: Profile::TIME_OPTIONS, message: "should not be blank" }, unless: :business_fields_mandatory_blank?
  validates :close_time, inclusion: { in: Profile::TIME_OPTIONS, message: "should not be blank" }, unless: :business_fields_mandatory_blank?
  validates :increase, length: { maximum: 6, message: "should not be greater than 6 digits." }, unless: :increase_blank?
  validates :increase_hourly, length: { maximum: 6, message: "should not be greater than 6 digits." }, unless: :increase_hourly_blank?

  validates :increase, numericality: { greater_than: 0, message: "should be greater than zero" }, unless: :weekend_pricing_blank?
  validates :increase_hourly, numericality: { greater_than: 0, message: "should be greater than zero" }, unless: :hourly_pricing_blank?

  HUMANIZED_ATTRIBUTES = {
    :phone => "Mobile No",
    :increase => "Rent Increase in % - Weekend/Seasonal,",
    :increase_hourly => "Rent Increase in % - Hourly,",
    :date_of_birth => "Birthday",
    :slug => "Username"
  }
  def self.human_attribute_name(attr, options = {})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  def gender_blank?
    gender.blank?
  end

  def about_blank?
    about.blank?
  end

  def business_fields_mandatory_blank?
    business_fields_mandatory.blank?
  end

  def increase_blank?
    increase == 0.00 || increase.blank?
  end

  def increase_hourly_blank?
    increase_hourly == 0.00 || increase_hourly.blank?
  end

  def weekend_pricing_blank?
    weekend_pricing.blank?
  end

  def hourly_pricing_blank?
    hourly_pricing.blank?
  end

  def phone_blank?
    phone.blank?
  end

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

  def business_type_name
    return Profile::BUSINESS_TYPE[0][0] if business_type == Profile::BUSINESS_TYPE[0][1]
    return Profile::BUSINESS_TYPE[1][0] if business_type == Profile::BUSINESS_TYPE[1][1]
  end

  def avail_days_arr
    init_availability unless avail_days
    avail_days.to_a
  end

  def weekend_days_arr
    weekend_days.blank? ? [] : weekend_days.to_a
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

  def title
    fullname = "#{first_name}-#{last_name}"
    fullname
  end

  def name
    "#{first_name} #{last_name}"
  end

  def init_availability
    update_columns avail_days: ["1","2","3","4","5"], open_time: "08:00", close_time: "17:00"
  end
end
