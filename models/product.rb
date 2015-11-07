class Product < ActiveRecord::Base
  extend FriendlyId
  #friendly_id :title, use: :slugged
  friendly_id :slug_candidates, use: :slugged
  def slug_candidates
    [
      [:title],
      [:title, :id]
    ]
  end
  def should_generate_new_friendly_id?
    title_changed?
  end

  include AlgoliaSearch

  algoliasearch if: :available? do
    attribute :title, :category_path, :description, :price, :created_at, :rate
    attribute :location_address, :operator
    tags do
      [listing_type, owner_type, category_slug, parent_cat, product_condition]
    end
    attributesToIndex [:title, :category_path, :description, :price, :created_at, :rate]
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
  belongs_to :user
  belongs_to :category

  has_many :ratings, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :transactions, dependent: :destroy
  has_many :images, as: :owner, dependent: :destroy

  has_one :location, as: :locatable, dependent: :destroy
  accepts_nested_attributes_for :location

  serialize :doc_requirement

  validates :title, presence: true
  validates :price, numericality: { greater_than: 0 }, unless: :for_free?
  validates :replacement_cost, numericality: { greater_than: 0 }, unless: :for_free?
  validates :security_deposit, numericality: { greater_than_or_equal_to: 0 }, unless: :for_free?
  validates :category_id, presence: true
  validates :listing_type, presence: true

  attr_accessor :image_ids

  WEIGHTS = ["Not applicable", "below 500 gms", "0.5-1 kg", "1-2 kg", "2-3 kg", "3-4 kg"]
  SHIP_PRICES = [0, 29, 49, 99, 149, 199]
  OPERATOR_TYPE = ["Dry Rental", "Wet Hire", "Both"]

  scope :active, -> {where available: true}
  scope :featured, -> {where featured: true}
  #boolean
  def available?
    available==true
  end

  def for_free?
    listing_type=='Free'
  end

  def for_rent?
    listing_type=='Rent'
  end

  def for_request?
    listing_type=='Requesting'
  end

  def for_sell?
    listing_type=='Sell'
  end

  def individual?
    owner_type=="Individual"
  end

  #get infos

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

  def disabled_days
    user.profile.disabled_days
  end

  def enabled_hours
    user.profile.enabled_hours
  end

  def min_h
    user.profile.min_h
  end

  def min_m
    user.profile.min_m
  end

  def unavailable_dates
    dates = []
    transactions.renting.each do |tran|
      (tran.startdate.to_date..tran.enddate.to_date).to_a.each do |d|
        dates << d.strftime("%Y-%m-%d")
      end
    end
    dates 
  end

  def first_avail
    d = DateTime.current
    date_str = d.strftime("%Y-%m-%d")
    if disabled_days.count < 7
      while disabled_days.include?(d.wday)
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
  def calculate_price(days, operator_type=0)
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

  def price_without_deposit(days, operator_type)
    amount = price*days + ship_price - discount_by_days(days)
    amount += operator_price if operator_type.to_i == 1
    amount
  end

  def tax_amount(days, operator_type)
    return 0 if for_free?
    price_without_deposit(days, operator_type)*tax/100
  end
  #end pricing

  def image
    url = images.first.file_url if images.first
    url = "img/6.png" if url.blank?
    url
  end

  def old_images
    arr = []
    arr << image_1_url unless image_1_url.blank?
    arr << image_2_url unless image_2_url.blank?
    arr << image_3_url unless image_3_url.blank?
    arr
  end

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

  def operator
    OPERATOR_TYPE[operator_type || 0]
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
    avail = !available
    update_column :available, avail
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
