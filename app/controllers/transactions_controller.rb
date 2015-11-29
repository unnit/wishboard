class TransactionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:callback]
  before_filter :authenticate_user!
  before_filter :set_transaction, only: [:accept, :deny, :checkout, :delete_non_coco]
  before_filter :check_product_owner, only: [:accept, :deny, :delete_non_coco]
  before_filter :set_product, only: [:new, :create, :checkout, :non_coco]
  before_filter :check_product_availability, only: [:new, :create]

  def new
    #TransactionsResetJob.set(wait: 4.minutes).perform_later
    params[:operator_type] = Product::OPERATOR_TYPE[0][1] if params[:operator_type].blank?
    params[:operator_type] = Product::OPERATOR_TYPE[1][1] if @product.operator_type == Product::OPERATOR_TYPE[1][1]
    @transaction = @product.transactions.build(startdate: session[:start_date_time], enddate: session[:end_date_time], operator_type: params[:operator_type])
    @transaction.user = current_user
    if @transaction.valid?
      @address = current_user.address || current_user.copy_address!
      if @product.owner_type == Product::OWNER_TYPE[0][1]
        @transaction.status = Transaction::TRANSACTION_STATUS[1][1]
        @transaction.amount = @product.calculate_price(@transaction.duration_days, params[:operator_type])
        @transaction.save
        redirect_to checkout_transaction_path(@transaction)
      end
    else
      flash[:danger] = @transaction.errors.full_messages.first
      redirect_to user_product_path(@product)
    end
  end

  def create
    params[:operator_type] = Product::OPERATOR_TYPE[0][1] if params[:operator_type].blank?
    params[:operator_type] = Product::OPERATOR_TYPE[1][1] if @product.operator_type == Product::OPERATOR_TYPE[1][1]
    @transaction = Transaction.new
    @transacrion.user = current_user
    @transaction.startdate = session[:start_date_time]
    @transaction.enddate = session[:end_date_time]
    @transaction.operator_type = params[:operator_type]
    @transaction.product = @product
    @transaction.amount = @product.calculate_price(@transaction.duration_days, params[:operator_type])
    @transaction.status = Transaction::TRANSACTION_STATUS[0][1]
    logger.info @product.owner_type
    if @transaction.save
      current_user.send_message([@transaction, @product.user], params[:message], "Request for #{@product.title}")
      TransactionMailer.order_request(@transaction, params[:message]).deliver_now
      redirect_to my_profile_profiles_path
    else
      flash[:danger] = @transaction.errors.full_messages.join("<br/>").html_safe
      render :new
    end
  end

  def non_coco
    unless @product.user == current_user
      flash[:danger] = "You can't execute this action"
      redirect_to root_path
      return
    end
    if params[:non_coco_start_date].blank? || params[:non_coco_end_date].blank?
      flash[:danger] = "Please select a date"
      redirect_to dashboard_profiles_path
      return
    end
    @transaction = Transaction.new
    @transaction.user = current_user
    @transaction.startdate = params[:non_coco_start_date]
    @transaction.enddate = params[:non_coco_end_date]
    @transaction.operator_type = Product::OPERATOR_TYPE[0][1]
    @transaction.product = @product
    @transaction.amount = 0
    @transaction.status = Transaction::TRANSACTION_STATUS[5][1]
    if @transaction.save
      redirect_to dashboard_profiles_path
      return
    end
  end

  def delete_non_coco
    if @transaction.destroy
      redirect_to dashboard_profiles_path
      return
    end
  end

  def checkout
    @transaction.amount
    @transaction.generate_txnid!
    @address = current_user.address || current_user.copy_address!
  end

  def accept
    @transaction.accept!
    redirect_to message_path(@transaction)
  end

  def deny
    @transaction.deny!
    redirect_to message_path(@transaction)
  end

  def callback
    id = params["TxId"].split("_").last
    @transaction = current_user.transactions.find_by_id id
    if params["TxStatus"] == "PG_REJECTED"
      flash[:danger] = params["TxMsg"]
      TransactionMailer.fail(@transaction, params["TxMsg"])
      redirect_to checkout_transaction_path(@transaction)
    else
      @transaction.paid!(params["transactionId"], params["amount"])
      @address = current_user.address
      @address.update_columns first_name: params["firstName"], last_name: params["lastName"], address1: params["addressStreet1"],
                              address2: params["addressStreet2"], city: params["addressCity"], zip: params["addressZip"], state: params["addressState"],
                              country: params["addressCountry"], mobile: params["mobileNo"], email: params["email"]
      render :thankyou
    end
  end

  private

  def set_product
    @product = Product.friendly.find params[:id]
    if params[:id].blank?
      @product = @transaction.product
    end
  end

  def set_transaction
    @transaction = Transaction.find params[:id]
  end

  def check_product_owner
    unless @transaction.seller == current_user
      flash[:danger] = "You can't execute this action"
      redirect_to root_path
    end
  end

  def check_product_availability
    search_start_day = session[:start_date_time].to_date.wday unless session[:start_date_time].blank?
    search_start_time = session[:start_date_time].split(" ").last unless session[:start_date_time].blank?
    search_end_day = session[:end_date_time].to_date.wday unless session[:end_date_time].blank?
    search_end_time = session[:end_date_time].split(" ").last unless session[:end_date_time].blank?

    search_start_date_time = session[:start_date_time].in_time_zone("Kolkata")
    search_end_date_time = session[:end_date_time].in_time_zone("Kolkata")

    if @product.transactions.renting.blank?
      if @product.enabled_days.include?("#{search_start_day}") && @product.enabled_days.include?("#{search_end_day}") && @product.enabled_hours.include?("#{search_start_time}") && @product.enabled_hours.include?("#{search_end_time}")
      else
        flash[:danger] = "Sorry, Item is not available for the selected dates."
        redirect_to user_product_path(@product)
        return
      end
    else
      @product.transactions.renting.each do |transaction|
        transaction_start_date_time =  transaction.startdate - 1
        transaction_end_date_time =  transaction.enddate + 1
        if @product.enabled_days.include?("#{search_start_day}") && @product.enabled_days.include?("#{search_end_day}") && @product.enabled_hours.include?("#{search_start_time}") && @product.enabled_hours.include?("#{search_end_time}") && ( ((search_start_date_time > transaction_end_date_time) && (search_end_date_time > transaction_end_date_time)) || ((search_start_date_time < transaction_start_date_time) && (search_end_date_time < transaction_start_date_time)) )
        else
          flash[:danger] = "Sorry, Item is not available for the selected dates."
          redirect_to user_product_path(@product)
          return
        end
      end
    end
  end

end
