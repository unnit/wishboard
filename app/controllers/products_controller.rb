class ProductsController < ApplicationController
  before_filter :authenticate_user!, only: [:new, :create, :edit, :destroy, :rate, :review, :update, :remove_image, :update_available, :update_admin_approved]
  before_filter :set_product, only: [:show, :edit, :rate, :review, :update, :destroy, :remove_image, :update_available, :get_price, :update_admin_approved]
  before_filter :authenticate_owner, only: [:edit, :update, :destroy, :remove_image, :update_available]
  before_filter :check_whether_edit_page, only: [:edit, :update, :remove_image]
  before_filter :date_check_before_search, only: [:index, :search]

  def index
    #product_paginate
    #@from_search_page = true
    product_search
  end

  def search
    #product_paginate
    add_breadcrumb "Home", root_path
    add_breadcrumb "Search Results", search_products_path
    product_search
    render :index
    return
  end

  def new
    if current_user.not_eligible_to_list?
      flash[:notice] = "Please fill the details before you list an item."
      redirect_to settings_business_path
    end
    @product = Product.new
    @product.build_location
  end

  def create
    @product = current_user.products.build(create_product_params)
    @product.hourly_price = 0 if @product.daily_type? || @product.hourly_price.blank?
    @product.listing_type = Product::LISTING_TYPE[1][1]
    sanitize_free_product if @product.for_free?
    if @product.save
      @product.update_parent_category!
      @product.location.update_lat_lng
      @product.reload
      create_showcase
      flash[:success] = "Item saved successfully and is under review process. It will be posted as soon as the review is completed.<br>You can edit, change the availability of your product from your <a href='/dashboard'>Dashboard</a>.".html_safe
      redirect_to user_product_path(@product.id)
    else
      set_category if @product.category
      flash[:danger] = @product.errors.full_messages.join('<br>')
      render :new
    end
  end

  def edit
    set_category
  end

  def update
    @product.billing_type = params[:product][:billing_type]
    @product.hourly_price = params[:product][:hourly_price]
    @product.hourly_price = 0 if @product.daily_type? || @product.hourly_price.blank?
    @product.admin_approved = false
    #Adding location manually as it is creating new row each time
    @product.location.name = params[:product][:location_attributes][:name]
    if @product.update(update_product_params)
      @product.reload
      if @product.for_free?
        sanitize_free_product
        @product.save
      end
      @product.update_parent_category!
      @product.location.update_lat_lng
      update_showcase
      flash[:success] = "Product updated successfully and is under review process. It will be posted as soon as the review is completed."
      redirect_to user_product_path(@product.id)
    else
      set_category if @product.category
      flash[:danger] = @product.errors.full_messages.join('<br>')
      render :edit
    end
  end

  def get_price
    price_without_discount = @product.price_without_discount(params[:days].to_i, params[:hours].to_i, params[:operator_type].to_i, params[:no_of_weekenddays].to_i, params[:end_day_weekend].to_i)

    discount = @product.discount_by_days(params[:days].to_i, params[:hours].to_i, params[:operator_type].to_i, params[:no_of_weekenddays].to_i, params[:end_day_weekend].to_i)

    sign = discount > 0 ? "-" : ""

    price_with_discount = @product.price_with_discount(params[:days].to_i, params[:hours].to_i, params[:operator_type].to_i, params[:no_of_weekenddays].to_i, params[:end_day_weekend].to_i)

    tax = @product.tax_amount(params[:days].to_i, params[:hours].to_i, params[:operator_type].to_i, params[:no_of_weekenddays].to_i, params[:end_day_weekend].to_i)

    pay_amount = @product.calculate_price(params[:days].to_i, params[:hours].to_i, params[:operator_type].to_i, params[:no_of_weekenddays].to_i, params[:end_day_weekend].to_i)

    render json: {price_without_discount: price_without_discount, discount: discount, sign: sign, price_with_discount: price_with_discount, tax: tax, pay_amount: pay_amount}
  end

  def show
    add_breadcrumb "Home", root_path
    add_breadcrumb "#{@product.category.parent_name.downcase.titleize}", category_path("#{@product.category.parent.slug}")
    add_breadcrumb "#{@product.category_name.downcase.titleize}", category_path("#{@product.category.slug}")
    add_breadcrumb "#{@product.title.downcase.titleize}", user_product_path(@product.id)
    unless @product.available?
      unless current_user
        redirect_to root_path
        return
      else
        unless current_user == @product.user || current_user.admin?
          redirect_to root_path
          return
        end
      end
    end
    @days = @product.daily_type? ? 1 : 0
    @hours = @product.hourly_type? ? 4 : 0
    @no_of_weekenddays = 0
    @end_day_weekend = 0
    unless session[:end_date_time].blank? || session[:start_date_time].blank?
      @days = @product.days_calculation_for_pricing(session[:start_date_time], session[:end_date_time])
      @hours = @product.hours_calculation_for_pricing(session[:start_date_time], session[:end_date_time])
      end_day = (session[:end_date_time].in_time_zone("Kolkata").to_date..session[:end_date_time].in_time_zone("Kolkata").to_date)
      @end_day_weekend = @product.no_of_weekenddays(end_day, @product.user.profile.weekend_days_arr.map(&:to_i))
      total_days = (session[:start_date_time].in_time_zone("Kolkata").to_date..session[:end_date_time].in_time_zone("Kolkata").to_date)
      @no_of_weekenddays = @product.no_of_weekenddays(total_days, @product.user.profile.weekend_days_arr.map(&:to_i))
      @no_of_weekenddays = @no_of_weekenddays - 1 if @hours > 0 && @end_day_weekend > 0
    end
  end

  def update_available
    if @product.update available: params[:available]
      render json: {success: true}
    else
      render json: {error: @product.errors.full_messages.first}
    end
  end

  def update_admin_approved
    if current_user.admin?
      @product.toggle!
      flash[:success] = @product.admin_approved == true ? "Aprroved successfully" : "Unaprroved successfully"
      redirect_to user_product_path(@product.id)
    end
  end

  def rate
    current_user.rate!(@product, params[:value])
    @product.reload
    @rate = params[:value].to_i
    respond_to :js
  end

  def review
    @review = current_user.reviews.create(product_id: @product.id, comment: params[:review][:comment])
    @product.reload
    respond_to :js
  end

  def sub_categories
    unless params[:category].blank?
      #category = Category.friendly.find params[:category]
      category = Category.find_by_id params[:category]
      @subs = category.subs
    end
    @subs ||=[]
    @selected = params[:selected]
    respond_to :js
  end

  def remove_image
    if @product.image_1.filename == params[:image]
      @product.remove_image_1!
    elsif @product.image_2.filename == params[:image]
      @product.remove_image_2!
    elsif @product.image_3.filename == params[:image]
      @product.remove_image_3!
    elsif @product.image_4.filename == params[:image]
      @product.remove_image_4!
    elsif @product.image_5.filename == params[:image]
      @product.remove_image_5!
    end
    if @product.save
      flash[:success] = "Image deleted successfully"
      redirect_to edit_product_path(@product.id)
      return
    else
      set_category
      @error_messages = @product.errors.full_messages.join('</li><li>')
      @product.reload
      render :edit
      return
    end
  end

  def category
    category = Category.friendly.find params[:id]
    parent_id = category.parent_id
    conditions = ["available = true and admin_approved = true"]
    if parent_id.blank?
      conditions[0]+=" and parent_category = ?"
    else
      conditions[0]+=" and category_id = ?"
    end
    conditions.push category.id
    @products = Product.where(conditions)
    unless @products.blank?
      add_breadcrumb "Home", root_path
      add_breadcrumb "#{@products.first.category.parent_name.downcase.titleize}", category_path("#{@products.first.category.parent.slug}")
      add_breadcrumb "#{@products.first.category_name.downcase.titleize}", category_path("#{@products.first.category.slug}") unless parent_id.blank?
    end
  end

  def all
    @products = Product.where("available = true and admin_approved = true")
    @from_all_page = true
    render :category
  end

  private
  def create_product_params
    params.require(:product).permit(:user_id, :title, :category_id, :price, :tax, :security_deposit, :operator_type, :operator_price, :discount_3, :discount_10, :discount_20,
                                    :discount_30, :discount_90, :available, :description, :owner_type, :product_condition, :tech_spec, :internal_id, :billing_type, :hourly_price,
                                    :terms_and_conditions, :year_of_manufacture, :image_1, :image_2, :image_3, :image_4, :image_5,
                                    :slug, {doc_requirement: []}, location_attributes: [:name])
  end

  def update_product_params
    params.require(:product).permit(:user_id, :title, :category_id, :price, :tax, :security_deposit, :operator_type, :operator_price, :discount_3, :discount_10, :discount_20,
                                    :discount_30, :discount_90, :available, :description, :owner_type, :product_condition, :tech_spec, :internal_id,
                                    :terms_and_conditions, :year_of_manufacture, :image_1, :image_2, :image_3, :image_4, :image_5,
                                    :slug, {doc_requirement: []})
  end

  def search_options
    page = params[:page] ||= 1
    h = {page: page}
    tags = []
    tags << params[:listing_type] unless params[:listing_type].blank?
    tags << params[:owner_type] unless params[:owner_type].blank?
    tags << params[:product_condition] unless params[:product_condition].blank?
    if !params[:sub_category_id].blank?
      cat = params[:sub_category_id]
    elsif !params[:category].blank?
      cat = params[:category]
    end
    tags << cat unless cat.blank?
    h[:tagFilters] = tags unless tags.blank?

    num = []
    num << ["available=1,(admin_approved=1)"]
    unless params[:price].blank?
      val = params[:price].split(",")
      num << ["price>#{val.first}","price<#{val.last}"]
    end
    h[:numericFilters] = num unless num.blank?
    h
  end

  def product_paginate
    #@products = params[:location].blank? ? Product.active : Product.active.near_by(params[:location], 10)
    #Product.reindex!
    if params[:tab] == '2'
      @products = Product.search(params[:term], search_options.merge({slave: "price"}))
    elsif params[:tab] == '3'
      @products = Product.search(params[:term], search_options.merge({slave: "price_desc"}))
    elsif params[:tab] == '4'
      @products = Product.new_posts.search(params[:term], search_options)
    else
      @products = Product.search(params[:term], search_options)
    end
    #@products_array = []
    #search_start_day = params[:start_date_time].to_date.wday
    #search_start_time = params[:start_date_time].split(" ").last
    #search_end_day = params[:end_date_time].to_date.wday
    #search_end_time = params[:end_date_time].split(" ").last
    #@products_filtered.each do |product|
    #  if product.enabled_days.include?("#{search_start_day}") && product.enabled_days.include?("#{search_end_day}") && product.enabled_hours.include?("#{search_start_time}") && product.enabled_hours.include?("#{search_end_time}")
    #  else
        #@products_filtered = @products_filtered.reject{|p| p.id == product.id}
    #  end
    #end
    #@products = @products_filtered
    #@products = Kaminari.paginate_array(@products_filtered).page(params[:page]).per(10)
  end

  def product_search
    @max_price = Product.maximum(:price)
    @min_price = Product.minimum(:price)
    conditions = ["available = true and admin_approved = true"]
    unless params[:category].blank?
      conditions[0]+=" and parent_category = ?"
      conditions.push params[:category]
    end
    unless params[:sub_category_id].blank?
      conditions[0]+=" and category_id = ?"
      conditions.push params[:sub_category_id]
    end
    unless params[:listing_type].blank?
      conditions[0]+=" and listing_type = ?"
      #conditions.push params[:listing_type]
      conditions.push Product::LISTING_TYPE[1][1]
    end
    unless params[:owner_type].blank?
      conditions[0]+=" and owner_type = ?"
      conditions.push params[:owner_type]
    end
    unless params[:product_condition].blank?
      conditions[0]+=" and product_condition = ?"
      conditions.push params[:product_condition]
    end
    unless params[:price].blank?
      unless params[:listing_type] == Product::LISTING_TYPE[0][1]
        start_price = params[:price].split(",").first.to_i
        end_price = params[:price].split(",").last.to_i
        conditions[0]+=" and price between ? and ?"
        conditions.push start_price
        conditions.push end_price
      end
    end
    if params[:tab] == '2'
      @products = Product.where(conditions).order(:price)
    elsif params[:tab] == '3'
      @products = Product.where(conditions).order(price: :desc)
    elsif params[:tab] == '4'
      @products = Product.where(conditions).order(created_at: :desc)
    else
      @products = Product.where(conditions).order(rate: :desc)
    end
    result_count = @products.count
    unless params[:start_date_time].blank?
      session[:start_date_time] = params[:start_date_time]
      @start_day = params[:start_date_time].to_date.wday
      @start_time = params[:start_date_time].split(" ").last
      @start_date_time = params[:start_date_time].in_time_zone("Kolkata")
    end
    unless params[:end_date_time].blank?
      session[:end_date_time] = params[:end_date_time]
      @end_day = params[:end_date_time].to_date.wday
      @end_time = params[:end_date_time].split(" ").last
      @end_date_time = params[:end_date_time].in_time_zone("Kolkata")
    end
    i = 0
    @products.each do |product|
      if product.transactions.renting.blank?
        if product.enabled_days.include?("#{@start_day}") && product.enabled_days.include?("#{@end_day}") && product.enabled_hours.include?("#{@start_time}") && product.enabled_hours.include?("#{@end_time}")
        else
          @products = @products.reject{|p| p.id == product.id}
          i+=1
        end
      else
        product.transactions.renting.each do |transaction|
          transaction_start_date_time =  transaction.startdate - GLOBAL_VARIABLES[:buffer_time_of_transaction].hour
          transaction_end_date_time =  transaction.enddate + GLOBAL_VARIABLES[:buffer_time_of_transaction].hour
          if product.enabled_days.include?("#{@start_day}") && product.enabled_days.include?("#{@end_day}") && product.enabled_hours.include?("#{@start_time}") && product.enabled_hours.include?("#{@end_time}") &&
            ( ((@start_date_time > transaction_end_date_time) && (@end_date_time > transaction_end_date_time)) || ((@start_date_time < transaction_start_date_time) && (@end_date_time < transaction_start_date_time)) )
          else
            @products = @products.reject{|p| p.id == product.id}
            i+=1
          end
        end
      end
    end
    filtered_count = @products.count
    suggest_availability if filtered_count == 0 && result_count > 0
    @products = @products.sort_by{|p| p.currently_available ? 0 : 1}
    @products = Kaminari.paginate_array(@products).page(params[:page]).per(21)
  end

  def suggest_availability
    @suggest_start_date = @start_date_time
    @suggest_end_date = @end_date_time
    if @start_day == GLOBAL_VARIABLES[:sunday]
      @suggest_start_date = @start_date_time + 1.day
      @suggest_end_date = @end_date_time + 1.day
    end
    if @end_day == GLOBAL_VARIABLES[:sunday]
      @suggest_end_date = @end_date_time + 1.day
    end
    if GLOBAL_VARIABLES[:bike_two_wheelers] == params[:category].to_i
      if @end_time.in_time_zone("Kolkata") < GLOBAL_VARIABLES[:bike_start_time].in_time_zone("Kolkata")
        @suggest_end_date = @suggest_end_date.change({ hour: GLOBAL_VARIABLES[:bike_start_hour], min: GLOBAL_VARIABLES[:bike_start_minute] })
      elsif @end_time.in_time_zone("Kolkata") > GLOBAL_VARIABLES[:bike_end_time].in_time_zone("Kolkata")
        @suggest_end_date = (@suggest_end_date + 1.day).change({ hour: GLOBAL_VARIABLES[:bike_start_hour], min: GLOBAL_VARIABLES[:bike_start_minute] })
      end
      if @start_time.in_time_zone("Kolkata") < GLOBAL_VARIABLES[:bike_start_time].in_time_zone("Kolkata")
        @suggest_start_date = @suggest_start_date.change({ hour: GLOBAL_VARIABLES[:bike_start_hour], min: GLOBAL_VARIABLES[:bike_start_minute] })
      elsif @start_time.in_time_zone("Kolkata") > GLOBAL_VARIABLES[:bike_end_time].in_time_zone("Kolkata")
        @suggest_start_date = (@suggest_start_date + 1.day).change({ hour: GLOBAL_VARIABLES[:bike_start_hour], min: GLOBAL_VARIABLES[:bike_start_minute] })
      end
    elsif GLOBAL_VARIABLES[:fashion_and_dress] == params[:category].to_i
      if @end_time.in_time_zone("Kolkata") < GLOBAL_VARIABLES[:dress_start_time].in_time_zone("Kolkata")
        @suggest_end_date = @suggest_end_date.change({ hour: GLOBAL_VARIABLES[:dress_start_hour], min: GLOBAL_VARIABLES[:dress_start_minute] })
      elsif @end_time.in_time_zone("Kolkata") > GLOBAL_VARIABLES[:dress_end_time].in_time_zone("Kolkata")
        @suggest_end_date = (@suggest_end_date + 1.day).change({ hour: GLOBAL_VARIABLES[:dress_start_hour], min: GLOBAL_VARIABLES[:dress_start_minute] })
      end
      if @start_time.in_time_zone("Kolkata") < GLOBAL_VARIABLES[:dress_start_time].in_time_zone("Kolkata")
        @suggest_start_date = @suggest_start_date.change({ hour: GLOBAL_VARIABLES[:dress_start_hour], min: GLOBAL_VARIABLES[:dress_start_minute] })
      elsif @start_time.in_time_zone("Kolkata") > GLOBAL_VARIABLES[:dress_end_time].in_time_zone("Kolkata")
        @suggest_start_date = (@suggest_start_date + 1.day).change({ hour: GLOBAL_VARIABLES[:dress_start_hour], min: GLOBAL_VARIABLES[:dress_start_minute] })
      end
    end
    if @suggest_start_date != @start_date_time || @suggest_end_date != @end_date_time
      @suggest_end_date = @suggest_end_date + 1.day if @suggest_start_date == @suggest_end_date
      @suggest_end_date = @suggest_start_date + 4.hours if ((@suggest_start_date + 4.hours) > @suggest_end_date)
      @suggest_start_date = @suggest_start_date.strftime("%d-%m-%Y %H:%M")
      @suggest_end_date = @suggest_end_date.strftime("%d-%m-%Y %H:%M")
      @msg = "Sorry, No products are available during the selected time frame.<br><br>Shall we edit your dates to a nearest value to check availability.".html_safe
    end
  end

  def set_product
    #params[:id] = params[:id].split('-').last
    @product = Product.friendly.find params[:id]
    #@product = Product.find params[:id]
  end

  def set_category
    unless @product.category.blank?
      @selected_cat = @product.category.parent
      @selected_sub = @product.category.name
      @selected_cat_name = @selected_cat.name
      @selected_cat_id = @selected_cat.id
      @selected_cat_not_featured = @selected_cat.not_featured?
    end
    @product.location || @product.build_location
  end

  def check_whether_edit_page
    @edit_page = true
  end

  def authenticate_owner
    redirect_to root_path unless(@product.user == current_user || current_user.admin?)
  end

  def date_check_before_search
    error_messages = []
    error_messages << "Please select Pick up Date" if params[:start_date_time].blank?
    error_messages << "Please select Drop off Date" if params[:end_date_time].blank?

    unless params[:start_date_time].blank? || params[:end_date_time].blank?
      if params[:start_date_time].in_time_zone("Kolkata") > params[:end_date_time].in_time_zone("Kolkata")
        error_messages << "Pick up Date cannot be greater than Drop off Date"
      end
      if params[:start_date_time].in_time_zone("Kolkata") < Time.now.in_time_zone("Kolkata")
        error_messages << "Pick up Date cannot be a past date."
      end
      if params[:end_date_time].in_time_zone("Kolkata") < Time.now.in_time_zone("Kolkata")
        error_messages << "Drop off Date cannot be a past date."
      end
    end
    unless error_messages.blank?
      flash[:alert] = error_messages.join(", ")
      redirect_to root_path
      return
    end
  end

  def sanitize_free_product
    @product.price = 0
    @product.security_deposit = 0
    @product.tax = 0
    @product.owner_type = 1
    @product.operator_type = 0
    @product.operator_price = 0
    @product.discount_3 = 0
    @product.discount_10 = 0
    @product.discount_20 = 0
    @product.discount_30 = 0
    @product.discount_90 = 0
    @product.tech_spec = ""
  end

  def create_showcase
    showcase = Showcase.new
    showcase.user = @product.user
    showcase.product = @product
    showcase.description = @product.description
    showcase.title = @product.title
    showcase.year = @product.year_of_manufacture
    showcase.image = @product.image.filename
    showcase.showcase_type = Showcase::SHOWCASE_VALUES[0]
    location = Location.new
    location.name = @product.location.name
    if showcase.save
      location.locatable_id = showcase.id
      location.locatable_type = 'Showcase'
      location.save
    end
  end

  def update_showcase
    showcase = @product.showcase
    showcase.description = @product.description
    showcase.title = @product.title
    showcase.year = @product.year_of_manufacture
    showcase.image = @product.image.filename
    showcase.location.name = @product.location.name
    showcase.save
  end

end
