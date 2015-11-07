class ProductsController < ApplicationController
  before_filter :authenticate_user!, only: [:new, :create, :edit, :destroy, :rate, :review, :update]
  before_filter :set_product, only: [:show, :edit, :rate, :review, :update, :destroy]
  before_filter :authenticate_owner, only: [:edit, :update, :destroy]

  # GET UI
  def edit
    set_category
    @images = @product.images
    @images = @product.images
  end

  def index
    product_paginate
  end

  def new
    @product = Product.new
    @product.build_location
    @images = @product.images
  end

  def search
    product_paginate
    render :index
  end

  def sub_categories
    unless params[:category].blank?
      category = Category.friendly.find params[:category]
      @subs = category.subs
    end
    @subs ||=[]
    @selected = params[:selected]
    respond_to :js
  end

  #Actions
  def create
    @product = current_user.products.build(product_params)
    set_images

    if @product.save
      @product.update_parent_category!
      @product.images << @images

      flash[:success] = "Product posted successful"
      redirect_to user_product_path(@product.user, @product)
    else
      set_category if @product.category
      render :new
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

  def update
    set_images
    if @product.update(product_params)
      @product.update_parent_category!
      flash[:success] = "Product updated successful"
      @product.images << @images
      redirect_to user_product_path(@product.user, @product)
    else
      set_category
      render :edit
    end
  end

  def update_available
    @product = Product.friendly.find params[:id]
    if @product.update available: params[:available]
      render json: {success: true}
    else
      render json: {error: @product.errors.full_messages.first}
    end
  end

  private
  def product_params
    params.require(:product).permit(:user_id, :category_id, :listing_type, :title, :price, :tax, :operator_type, :operator_price, :ship_price, :discount_3, :discount_10, :discount_20,
                                    :discount_30, :discount_90, :available_date, :description, :owner_type, :product_condition, :tech_spec, 
                                    :weekly_rent, :monthly_rent, :security_deposit, :terms_and_conditions, :year_of_manufacture, :replacement_cost,
                                    :image_1, :image_2, :image_3, :slug, {doc_requirement: []}, location_attributes: [:name, :lat, :lng])
  end

  def search_options
    # result = {}
    # result[:listing_type] = params[:listing_type] unless params[:listing_type].blank?
    # result[:owner_type] = params[:owner_type] unless params[:owner_type].blank?
    # if !params[:sub_category_id].blank?
    #   result[:category_id] = params[:sub_category_id]
    # elsif !params[:category].blank?
    #   result[:parent_category_id] = params[:category]
    # end
      
    # result[:product_condition] = params[:product_condition] unless params[:product_condition].blank?
    # result[:price] = params[:price] unless params[:price].blank?
    # result[:weekly_rent] = params[:weekly_rent] unless params[:weekly_rent].blank?
    # result[:monthly_rent] = params[:monthly_rent] unless params[:monthly_rent].blank?
    # result[:location] = params[:location] unless params[:location].blank?
    # result
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

    unless params[:price].blank?
      val = params[:price].split(",")
      h[:numericFilters] = ["price>#{val.first}","price<#{val.last}"]
    end
    h
  end

  def product_paginate
    @products = params[:location].blank? ? Product.active : Product.active.near_by(params[:location], 10)
    if params[:tab] == '2'
      @products = @products.search(params[:term], search_options.merge({slave: "price"}))
    elsif params[:tab] == '3'
      @products = @products.search(params[:term], search_options.merge({slave: "price_desc"}))
    elsif params[:tab] == '4'
      @products = @products.new_posts.search(params[:term], search_options)
    else
      @products = @products.search(params[:term], search_options)
    end
  end

  def set_images
    @images = []
    if ids = params[:product][:image_ids]
      @images = Image.find ids.split(",") unless ids.blank?
    end
  end

  def set_product
    @product = Product.friendly.find params[:id]
  end

  def set_category
    @selected_cat = @product.category.parent_id
    @selected_sub = @product.category.name
    @product.location || @product.build_location
  end

  def authenticate_owner
    redirect_to root_path unless(@product.user == current_user || current_user.admin?)
  end
end