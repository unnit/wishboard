class Product < ActiveRecord::Base
  paginates_per 10
  extend FriendlyId
  #friendly_id :title, use: :slugged
  friendly_id :slug_candidates, use: :slugged
  def seo_slug
    unless id.blank?
      id = self.id
    else
      if Product.maximum(:id).blank?
        id = 1
      else
        id = Product.maximum(:id).next
      end
    end
    if listing_type == Product::LISTING_TYPE[0][1]
      type_of_listing = "free"
    elsif listing_type == Product::LISTING_TYPE[1][1]
      type_of_listing = "rent"
    end
    slug = "#{title}-for-#{type_of_listing}-in-#{location.name}-#{id}" if for_rent? || for_free?
    slug = "Searching-for-#{title}-in-#{location.name}-#{id}" if for_request?
    slug
  end
  def slug_candidates
    [
      :seo_slug
    ]
  end
  def should_generate_new_friendly_id?
    title_changed? || listing_type_changed? || location.name_changed?
  end

  attr_accessor :start_date_time, :end_date_time

  include AlgoliaSearch

  algoliasearch do
    attribute :title, :category_path, :description, :price, :created_at, :rate, :available, :admin_approved
    attribute :location_address
    tags do
      [listing_type, owner_type, category_slug, parent_cat, product_condition]
    end
    attributesToIndex [:title, :category_path, :description, :price, :created_at, :rate, :location_address, :available, :admin_approved]
    add_slave 'admin_search', per_environment: true do
      attributesToIndex [:title, :category_path]
    end

    customRanking ['desc(rate)']
    add_slave 'price', per_environment: true do
      customRanking ['asc(price)']
    end

    add_slave 'price_desc', per_environment: true do
      customRanking ['desc(price)']
    end
    hitsPerPage 10
  end
  mount_uploader :image_1, ImageUploader
  mount_uploader :image_2, ImageUploader
  mount_uploader :image_3, ImageUploader
  mount_uploader :image_4, ImageUploader
  mount_uploader :image_5, ImageUploader
  belongs_to :user
  belongs_to :category

  has_many :ratings, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :transactions, dependent: :destroy

  has_one :location, as: :locatable, dependent: :destroy
  accepts_nested_attributes_for :location

  serialize :doc_requirement

  WEIGHTS = ["Not applicable", "below 500 gms", "0.5-1 kg", "1-2 kg", "2-3 kg", "3-4 kg"]
  SHIP_PRICES_VALUES = [ 0, 29, 49, 99, 149, 199 ]
  SHIP_PRICES_WITH_WEIGHTS = [ ["0 ( Not applicable )", 0], ["29 ( below 500 gms )", 29], ["49 ( 0.5-1 kg )", 49], ["99 ( 1-2 kg )", 99], [ "149 ( 2-3 kg )", 149], ["199 ( 3-4 kg )", 199] ]
  OPERATOR_TYPE = [["Product only", 0], ["With Operator/Driver (Assisted)", 1], ["Both", 2]]
  OPERATOR_TYPE_VALUES = [0, 1, 2]
  PRODUCT_CONDITION = [["New/Unboxed", "0"], ["Excellent (Well Maintained)", "1"], ["Used", "2"], ["Not Functional", "3"]]
  PRODUCT_CONDITION_VALUES = ["0", "1", "2", "3"]
  OWNER_TYPE = [["Instant", "0"], ["After Confirmation", "1"]]
  OWNER_TYPE_VALUES = ["0", "1"]
  LISTING_TYPE = [["Free", "0"], ["Rent", "1"]]
  LISTING_TYPE_VALUES = ["0", "1"]
  AVAILABLE = [["Available", true], ["Not Available", false]]
  AVAILABLE_VALUES = [true, false]
  YEAR_OF_MANUFACTURE = (1947..Time.now.year).to_a.reverse

  validates :title, :category_id, :listing_type, :description, :terms_and_conditions, :doc_requirement, presence: true

  validates :title, length: { maximum: 80 }
  validates :description, length: { maximum: 1000 }
  validates :terms_and_conditions, length: { maximum: 65000 }
  validates :tech_spec, length: { maximum: 65000 }
  validates :price, :security_deposit, :tax, length: { maximum: 10 }

  #validates :ship_price, inclusion: { in: Product::SHIP_PRICES_VALUES, message: "should not be blank" }
  validates :product_condition, inclusion: { in: Product::PRODUCT_CONDITION_VALUES, message: "should not be blank" }
  validates :owner_type, inclusion: { in: Product::OWNER_TYPE_VALUES, message: "should not be blank" }, unless: :for_free?
  validates :operator_type, inclusion: { in: Product::OPERATOR_TYPE_VALUES, message: "should not be blank" }, unless: :for_free?
  validates :year_of_manufacture, inclusion: { in: Product::YEAR_OF_MANUFACTURE, message: "should not be blank" }
  validates :available, inclusion: { in: Product::AVAILABLE_VALUES, message: "should not be blank" }

  validates :price, numericality: { greater_than_or_equal_to: 0, message: "should be greater than or equal to zero" }, unless: :for_free?
  validates :security_deposit, numericality: { greater_than_or_equal_to: 0, message: "should be greater than or equal to zero" }, unless: :for_free?
  validates :tax, numericality: { greater_than_or_equal_to: 0, message: "should be greater than or equal to zero" }, unless: :for_free?
  validates :operator_price, numericality: { greater_than_or_equal_to: 0, message: "should be greater than or equal to zero" }, unless: :for_free?
  validates :discount_3, numericality: { greater_than_or_equal_to: 0, message: "should be greater than or equal to zero" }, unless: :for_free?
  validates :discount_10, numericality: { greater_than_or_equal_to: 0, message: "should be greater than or equal to zero" }, unless: :for_free?
  validates :discount_20, numericality: { greater_than_or_equal_to: 0, message: "should be greater than or equal to zero" }, unless: :for_free?
  validates :discount_30, numericality: { greater_than_or_equal_to: 0, message: "should be greater than or equal to zero" }, unless: :for_free?
  validates :discount_90, numericality: { greater_than_or_equal_to: 0, message: "should be greater than or equal to zero" }, unless: :for_free?

  validate :image_presence

  scope :active, -> {where ('available = true and admin_approved = true')}
  scope :featured, -> {where featured: true}

  HUMANIZED_ATTRIBUTES = {
    owner_type: "Booking Type",
    price: "Rent"
  }
  def self.human_attribute_name(attr, options = {})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  #validations
  def image_presence
    if image_1.blank? && image_2.blank? && image_3.blank? && image_4.blank? && image_5.blank?
      errors.add( :base, "Please make sure you have atleast one image for your item." )
    end
  end

  #boolean
  def available?
    available==true && admin_approved==true
  end

  def for_free?
    listing_type==Product::LISTING_TYPE[0][1]
  end

  def for_rent?
    listing_type==Product::LISTING_TYPE[1][1]
  end

  def for_request?
    listing_type==2
  end

  def for_sell?
    listing_type==3
  end

  def individual?
    owner_type==1
  end

  #get infos
  def listing_type_name
    return Product::LISTING_TYPE[0][0] if for_free?
    return Product::LISTING_TYPE[1][0] if for_rent?
  end

  def product_condition_name
    return Product::PRODUCT_CONDITION[0][0] if product_condition == Product::PRODUCT_CONDITION[0][1]
    return Product::PRODUCT_CONDITION[1][0] if product_condition == Product::PRODUCT_CONDITION[1][1]
    return Product::PRODUCT_CONDITION[2][0] if product_condition == Product::PRODUCT_CONDITION[2][1]
    return Product::PRODUCT_CONDITION[3][0] if product_condition == Product::PRODUCT_CONDITION[3][1]
  end

  def image
    image_1
  end

  def image_url
    image_1_url
  end

  def images
    arr = []
    arr << image_1 unless image_1.blank?
    arr << image_2 unless image_2.blank?
    arr << image_3 unless image_3.blank?
    arr << image_4 unless image_4.blank?
    arr << image_5 unless image_5.blank?
    arr
  end

  def image_urls
    arr = []
    arr << image_1_url unless image_1_url.blank?
    arr << image_2_url unless image_2_url.blank?
    arr << image_3_url unless image_3_url.blank?
    arr << image_4_url unless image_4_url.blank?
    arr << image_5_url unless image_5_url.blank?
    arr
  end

  def self.distinct_parent_category
    distinct_parent_category = []
    Product.select(:parent_category).distinct.each do |c|
      category = Category.find_by_name c.parent_category
      distinct_parent_category << category
    end
    return distinct_parent_category
  end

  def category_name
    category.name if category
  end

  def category_path
    category.name_with_parent if category
  end

  def category_slug
    category.slug if category
  end

  def parent_cat
    cat = Category.find_by_name parent_category
    return cat.slug if cat
  end

  def documents
    doc_requirement.join ", " unless doc_requirement.blank?
  end

  def service_charge(o_type)
    o_type == 0 ? 0 :  operator_price
  end

  def price_label
    for_sell? ? "Price" : "Daily Rent"
  end

  def enabled_days
      user.profile.avail_days_arr
  end

  def disabled_days
    user.profile.disabled_days
  end

  def self.create_hours(parameters)
    start_time = parameters[:start_time] ? parameters[:start_time] : 0
    end_time = parameters[:end_time] ? parameters[:end_time] : 24.hours
    increment = parameters[:increment] ? parameters[:increment] : 30.minutes
    Array.new(1 + (end_time - start_time)/increment) do |i|
      #["#{(Time.now.midnight + (i*30.minutes) + start_time).strftime('%H:%M')} #{(Time.now.midnight + (i*30.minutes) + start_time).strftime('(%I:%M %p)')}", (Time.now.midnight + (i*30.minutes) + start_time).strftime("%H:%M")]
      (Time.now.midnight + (i*30.minutes) + start_time).strftime("%H:%M")
    end
  end

  def enabled_hours
    start_time_hour = min_h
    start_time_minute = min_m
    start_time_minute = 0.5 if start_time_minute == 30
    start_time = start_time_hour+start_time_minute
    end_time_hour = max_h
    end_time_minute = max_m
    end_time_minute = 0.5 if end_time_minute == 30
    end_time = end_time_hour+end_time_minute
    Product.create_hours(:start_time => start_time.hours, :end_time => end_time.hours)
  end

  def min_h
    user.profile.min_h
  end

  def min_m
    user.profile.min_m
  end

  def max_h
    user.profile.max_h
  end

  def max_m
    user.profile.max_m
  end

  def unavailable_dates
    dates = []
    transactions.renting.each do |tran|
      (tran.startdate.to_date..tran.enddate.to_date).to_a.each do |d|
        dates << d
      end
    end
    dates
  end

  def first_avail
    d = DateTime.current.in_time_zone(TZInfo::Timezone.get('Asia/Kolkata'))
    date_str = d.strftime("%Y-%m-%d")
    if disabled_days.count < 7
      while disabled_days.include?("#{d.wday}")
        d = d + 1.day
      end
      date_str = d.strftime("%Y-%m-%d")
      if unavailable_dates.include?(date_str)
        date_str = unavailable_dates.last
      end
    end
    date_str
  end

  #pricing
  def calculate_price(days, operator_type)
    return ship_price if for_free?
    amount = price_without_deposit(days, operator_type) + tax_amount(days, operator_type) + security_deposit
    amount
  end

  def discount_by_days(days)
    d = 0
    if days > 90
      d = discount_90 || 0
    elsif days > 30
      d = discount_30 || 0
    elsif days > 20
      d = discount_20 || 0
    elsif days > 10
      d = discount_10 || 0
    elsif days > 3
      d = discount_3 || 0
    end
    discount = d.to_f/100
    discount * price * days
  end

  def discount_percent(days)
    d = 0
    if days > 90
      d = discount_90 || 0
    elsif days > 30
      d = discount_30 || 0
    elsif days > 20
      d = discount_20 || 0
    elsif days > 10
      d = discount_10 || 0
    elsif days > 3
      d = discount_3 || 0
    end
    d
  end

  def price_without_deposit(days, operator_type)
    amount = price*days + ship_price - discount_by_days(days)
    amount += operator_price if operator_type.to_i == Product::OPERATOR_TYPE[1][1]
    amount
  end

  def tax_amount(days, operator_type)
    return 0 if for_free?
    price_without_deposit(days, operator_type)*tax/100
  end
  #end pricing

  def lat
    location ? location.lat : ""
  end

  def lng
    location ? location.lng : ""
  end

  def location_address
    location.name if location
  end

  def name
    title
  end

  def reviews_count
    return "( no ) Reviews" if reviews.blank?
    return "( 1 ) Review" if reviews.count == 1
    "( #{reviews.count} ) Reviews"
  end

  def rental_status
    unavailable_dates.include?(Date.current) ? "Out for rental" : "available"
  end

  #actions
  def set_rate!
    update_column :rate, ratings.average(:value).round
  end

  def toggle!
    avail = !admin_approved
    update_column :admin_approved, avail
  end

  def toggle_featured!
    feature = !featured
    update_column :featured, feature
  end

  def update_parent_category!
    update_column :parent_category, category.parent_name if category
  end
  #class methos
  class << self

    def best_deal
      order(rate: :desc).order(:price)
    end

    def new_posts
      where("products.created_at > ?", DateTime.now - 2.days)
    end

    def near_by(address, distance=10)
      loc_ids = Location.near_by(address, distance).map(&:id)
      joins(:location).where("locations.id in(?)", loc_ids)
    end

    # def search(term, options={})
    #   if term.blank?
    #     results = all
    #   else
    #     results = joins(:category).where("lower(products.title) like ? or lower(categories.name) like ? or lower(products.parent_category) like ?", "%#{term.downcase}%", "%#{term.downcase}%", "%#{term.downcase}%")
    #   end
    #   options.each do |key, value|
    #     unless value.blank?
    #       #begin
    #         if key==:location
    #           results = results.near_by(value)
    #         elsif key==:parent_category_id
    #           category = Category.friendly.find(value)
    #           sub_ids = category.subs.map(&:id)
    #           results = results.where category_id: sub_ids
    #         else
    #           if key == :price || key == :weekly_rent || key == :monthly_rent
    #             range = value.split(",")
    #             min = range.first.to_f
    #             max = range.last.to_f
    #             value = min..max
    #           end
    #           results = results.where(key => value)
    #         end
    #       #rescue
    #         #results = []
    #       #end
    #     end
    #   end
    #   results
    # end
  end

end
