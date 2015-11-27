class TransactionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:callback]
  before_filter :authenticate_user!, except: [:get_price]
  before_filter :set_product, only: [:new, :create, :get_price]
  before_filter :set_transaction, only: [:accept, :deny]
  before_filter :check_product_availability, only: [:new]

  def new
    TransactionsResetJob.set(wait: 4.minutes).perform_later
    @transaction = @product.transactions.build(startdate: session[:start_date_time], enddate: session[:end_date_time], operator_type: params[:operator_type])
    @transaction.user = current_user
    if @transaction.valid?
      if @product.owner_type == Product::OWNER_TYPE[0][1]
        @transaction.status = Transaction::TRANSACTION_STATUS[1][1]
        @transaction.amount = @product.calculate_price(@transaction.duration_days, params[:operator_type])
        @transaction.save
        redirect_to checkout_transaction_path(@transaction)
      end
      @address = current_user.address || current_user.copy_address!
    else
      flash[:danger] = @transaction.errors.full_messages.first
      redirect_to user_product_path(@product)
    end
  end

  def create
    @transaction = Transaction.new
    @transacrion.user = current_user
    @transaction.startdate = session[:start_date_time]
    @transaction.enddate = session[:end_date_time]
    @transaction.operator_type = params[:operator_type]
    @transaction.product = @product
    @transaction.amount = @product.calculate_price(@transaction.duration_days, params[:operator_type])
    @transaction.status = Transaction::TRANSACTION_STATUS[0][1]
    logger.info '********************'
    logger.info '---------CREATE---------------'
    logger.info @product.owner_type
    logger.info '********************'
    if @transaction.save
      current_user.send_message([@transaction, @product.user], params[:message], "Request for #{@product.title}")
      TransactionMailer.order_request(@transaction, params[:message]).deliver_now

      redirect_to my_profile_profiles_path
    else
      flash[:danger] = @transaction.errors.full_messages.join("<br/>").html_safe
      render :new
    end
  end

  def checkout
    @transaction = current_user.transactions.find params[:id]
    @product = @transaction.product
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
  end

  def set_transaction
    @transaction = Transaction.find params[:id]
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

    transaction_start_date_time =  @product.transactions.renting.first.startdate - 1.hour unless @product.transactions.renting.blank?
    transaction_end_date_time =  @product.transactions.renting.first.enddate + 1.hour unless @product.transactions.renting.blank?

    if transaction_start_date_time.blank? && transaction_end_date_time.blank?
      if @product.enabled_days.include?("#{search_start_day}") && @product.enabled_days.include?("#{search_end_day}") && @product.enabled_hours.include?("#{search_start_time}") && @product.enabled_hours.include?("#{search_end_time}")
      else
        flash[:danger] = "Sorry, Item is not available for the selected dates.1st"
        redirect_to user_product_path(@product)
        return
      end
    else
      if @product.enabled_days.include?("#{search_start_day}") && @product.enabled_days.include?("#{search_end_day}") && @product.enabled_hours.include?("#{search_start_time}") && @product.enabled_hours.include?("#{search_end_time}") && ( ((search_start_date_time > transaction_end_date_time) && (search_end_date_time > transaction_end_date_time)) || ((search_start_date_time < transaction_start_date_time) && (search_end_date_time < transaction_start_date_time)) )
      else
        flash[:danger] = "Sorry, Item is not available for the selected dates."
        redirect_to user_product_path(@product)
        return
      end
    end
  end

end
