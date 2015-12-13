class ProductsController < ApplicationController
  before_filter :authenticate_user!, only: [:new, :create, :edit, :destroy, :rate, :review, :update, :remove_image]
  before_filter :set_product, only: [:show, :edit, :rate, :review, :update, :destroy, :remove_image, :update_available, :get_price]
  before_filter :authenticate_owner, only: [:edit, :update, :destroy, :remove_image, :update_available]
  before_filter :check_whether_edit_page, only: [:edit, :update, :remove_image]

  def index
    #product_paginate
    #@from_search_page = true
    product_search
  end

  def search
    #product_paginate
    error_messages = []
    error_messages << "Please select Pickup Date" if params[:start_date_time].blank?
    error_messages << "Please select Drop off Date" if params[:end_date_time].blank?

    unless params[:start_date_time].blank? || params[:end_date_time].blank?
      if params[:start_date_time].in_time_zone("Kolkata") > params[:end_date_time].in_time_zone("Kolkata")
        error_messages << "Pickup Date cannot be greater than Drop off Date"
      end
    end
    unless error_messages.blank?
      flash[:alert] = error_messages.join(", ")
      redirect_to root_path
      return
    end
    product_search
    render :index
    return
  end

  def new
    @product = Product.new
    @product.build_location
  end

  def create
    @product = current_user.products.build(create_product_params)
    @product.listing_type = Product::LISTING_TYPE[1][1]
    if @product.listing_type == Product::LISTING_TYPE[0][1]
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
    if @product.save
      #@product.reload
      #logger.info '*****************'
      #logger.info @product.slug
      #logger.info '******************'
      #@product.slug = "#{@product.slug}" + "-#{@product.id}"
      #@product.save
      @product.update_parent_category!
      @product.location.update_lat_lng
      flash[:success] = "Item saved successfully and is under review process. It will be posted as soon as the review is completed."
      redirect_to user_product_path(@product)
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
    #Adding location manually as it is creating new row each time
    @product.admin_approved = false
    @product.location.name = params[:product][:location_attributes][:name]
    if @product.update(update_product_params)
      if @product.listing_type == Product::LISTING_TYPE[0][1]
        @product.reload
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
        @product.save
      end
      @product.update_parent_category!
      @product.location.update_lat_lng
      flash[:success] = "Product updated successfully"
      redirect_to user_product_path(@product)
    else
      set_category if @product.category
      flash[:danger] = @product.errors.full_messages.join('<br>')
      render :edit
    end
  end

  def get_price
    unless params[:enddate].blank? || params[:startdate].blank?
      days = (params[:enddate].to_date - params[:startdate].to_date).to_i
    end
    days = 1 if days == 0 || days.blank?
    pay_amount = @product.calculate_price(days, params[:operator_type])
    discount = @product.discount_by_days(days)
    tax = @product.tax_amount(days, params[:operator_type])
    sign = discount > 0 ? "-" : ""
    render json: {days: days,tax: tax, total_price: @product.price*days, pay_amount: pay_amount, discount: discount, sign: sign}
  end

  def show
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
    @days = 1
    unless session[:end_date_time].blank? || session[:start_date_time].blank?
      hours = (session[:end_date_time].in_time_zone("Kolkata") - session[:start_date_time].in_time_zone("Kolkata"))/3600
      days_not_rounded = hours/24
      if days_not_rounded > days_not_rounded.to_i
        @days = days_not_rounded.to_i + 1
      else
        @days = days_not_rounded.to_i
      end
    end
  end

  def update_available
    if @product.update available: params[:available]
      render json: {success: true}
    else
      render json: {error: @product.errors.full_messages.first}
    end
  end

  def destroy
    @product.destroy
    respond_to :js
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
      category = Category.find_by_name params[:category]
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
      redirect_to edit_product_path(@product)
      return
    else
      set_category
      @error_messages = @product.errors.full_messages.join('</li><li>')
      @product.reload
      render :edit
      return
    end
  end

  private
  def create_product_params
    params.require(:product).permit(:user_id, :title, :category_id, :price, :tax, :security_deposit, :operator_type, :operator_price, :discount_3, :discount_10, :discount_20,
                                    :discount_30, :discount_90, :available, :description, :owner_type, :product_condition, :tech_spec,
                                    :terms_and_conditions, :year_of_manufacture, :image_1, :image_2, :image_3, :image_4, :image_5,
                                    :slug, {doc_requirement: []}, location_attributes: [:name])
  end

  def update_product_params
    params.require(:product).permit(:user_id, :title, :category_id, :price, :tax, :security_deposit, :operator_type, :operator_price, :discount_3, :discount_10, :discount_20,
                                    :discount_30, :discount_90, :available, :description, :owner_type, :product_condition, :tech_spec,
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
    session[:start_date_time] = params[:start_date_time] unless params[:start_date_time].blank?
    session[:end_date_time] = params[:end_date_time] unless params[:end_date_time].blank?

    logger.info '*************************'
    logger.info @products.count
    logger.info '*************************'

    search_start_day = params[:start_date_time].to_date.wday unless params[:start_date_time].blank?
    search_start_time = params[:start_date_time].split(" ").last unless params[:start_date_time].blank?
    search_end_day = params[:end_date_time].to_date.wday unless params[:end_date_time].blank?
    search_end_time = params[:end_date_time].split(" ").last unless params[:end_date_time].blank?

    search_start_date_time = params[:start_date_time].in_time_zone("Kolkata")
    search_end_date_time = params[:end_date_time].in_time_zone("Kolkata")

    i = 0
    @products.each do |product|

      if product.transactions.renting.blank?
        if product.enabled_days.include?("#{search_start_day}") && product.enabled_days.include?("#{search_end_day}") && product.enabled_hours.include?("#{search_start_time}") && product.enabled_hours.include?("#{search_end_time}")
        else
          @products = @products.reject{|p| p.id == product.id}
          i+=1
          logger.info '********** Removed111'
          logger.info i
        end
      else
        product.transactions.renting.each do |transaction|
          transaction_start_date_time =  transaction.startdate - GLOBAL_VARIABLES[:buffer_time_of_transaction].hour
          transaction_end_date_time =  transaction.enddate + GLOBAL_VARIABLES[:buffer_time_of_transaction].hour
          logger.info '**************************'
          logger.info search_start_date_time
          logger.info '**************************'
          logger.info '**************************'
          logger.info transaction_end_date_time
          logger.info '**************************'
          if product.enabled_days.include?("#{search_start_day}") && product.enabled_days.include?("#{search_end_day}") && product.enabled_hours.include?("#{search_start_time}") && product.enabled_hours.include?("#{search_end_time}") && ( ((search_start_date_time > transaction_end_date_time) && (search_end_date_time > transaction_end_date_time)) || ((search_start_date_time < transaction_start_date_time) && (search_end_date_time < transaction_start_date_time)) )
          else
            @products = @products.reject{|p| p.id == product.id}
            i+=1
            logger.info '********** Removed'
            logger.info i
          end
        end
      end
    end
    @products = Kaminari.paginate_array(@products).page(params[:page]).per(10)
  end

  def set_product
    params[:id] = params[:id].split('-').last
    @product = Product.friendly.find params[:id]
  end

  def set_category
    @selected_cat = @product.category.parent_name
    @selected_sub = @product.category.name
    @product.location || @product.build_location
  end

  def check_whether_edit_page
    @edit_page = true
  end

  def authenticate_owner
    redirect_to root_path unless(@product.user == current_user || current_user.admin?)
  end
end
