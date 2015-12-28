class TransactionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:callback]
  before_filter :authenticate_user!
  before_filter :set_transaction, only: [:accept, :deny, :checkout, :delete_non_coco, :check_status_and_save_address_of_transaction]
  before_filter :check_product_owner, only: [:accept, :deny, :delete_non_coco]
  before_filter :set_product, only: [:new, :create, :non_coco]
  before_filter :check_product_availability, only: [:new, :create]
  before_filter :check_session_value_and_past_dates_and_operator_type, only: [:new, :create]
  before_filter :product_availability_for_accepted, only: [:checkout]
  before_filter :basic_checks_before_checkout, only: [:checkout]

  def new
    @transaction = @product.transactions.build(startdate: session[:start_date_time], enddate: session[:end_date_time], operator_type: params[:operator_type])
    @transaction.user = current_user
    if @transaction.valid?
      @address = current_user.address || current_user.copy_address!
      if @product.owner_type == Product::OWNER_TYPE[0][1]
        ### -----Asigning all values to transaction table
        total_days = ( session[:start_date_time].in_time_zone("Kolkata").to_date..session[:end_date_time].in_time_zone("Kolkata").to_date)
        @no_of_weekenddays = @product.no_of_weekenddays(total_days, @product.user.profile.weekend_days_arr.map(&:to_i))
        @transaction.status = Transaction::TRANSACTION_STATUS[1][1]
        @transaction.operator_price = @product.operator_price if params[:operator_type] == Product::OPERATOR_TYPE[1][1]
        @transaction.daily_rent = @product.price
        @transaction.days = @transaction.duration_days
        @transaction.weekend_rent = @product.seasonal_weekend_pricing(@no_of_weekenddays)
        @transaction.weekend_days = @no_of_weekenddays
        @transaction.rent_without_discount = @product.price_without_discount(@transaction.duration_days, params[:operator_type].to_i, @no_of_weekenddays)
        @transaction.discounts = @product.discount_by_days(@transaction.duration_days, params[:operator_type].to_i, @no_of_weekenddays)
        @transaction.rent_with_discount = @product.price_with_discount(@transaction.duration_days, params[:operator_type].to_i, @no_of_weekenddays)
        @transaction.tax = @product.tax_amount(@transaction.duration_days, params[:operator_type].to_i, @no_of_weekenddays)
        @transaction.refundable_security_deposit = @product.security_deposit
        @transaction.amount = @product.calculate_price(@transaction.duration_days, params[:operator_type].to_i, @no_of_weekenddays)
        @transaction.save
        ###########-----------------------------
        TransactionsResetJob.set(wait: GLOBAL_VARIABLES[:time_out].minutes).perform_later
        redirect_to checkout_transaction_path(@transaction)
      end
    else
      flash[:danger] = @transaction.errors.full_messages.first
      redirect_to user_product_path(@product.id)
    end
  end

  def create
    @transaction = Transaction.new
    @transaction.user = current_user
    @transaction.startdate = session[:start_date_time]
    @transaction.enddate = session[:end_date_time]
    @transaction.operator_type = params[:operator_type]
    @transaction.operator_price = @product.operator_price if params[:operator_type] == Product::OPERATOR_TYPE[1][1]
    @transaction.product = @product
    ### -----Asigning all values to transaction table
    total_days = ( session[:start_date_time].in_time_zone("Kolkata").to_date..session[:end_date_time].in_time_zone("Kolkata").to_date)
    @no_of_weekenddays = @product.no_of_weekenddays(total_days, @product.user.profile.weekend_days_arr.map(&:to_i))
    @transaction.daily_rent = @product.price
    @transaction.days = @transaction.duration_days
    @transaction.weekend_rent = @product.seasonal_weekend_pricing(@no_of_weekenddays)
    @transaction.weekend_days = @no_of_weekenddays
    @transaction.rent_without_discount = @product.price_without_discount(@transaction.duration_days, params[:operator_type].to_i, @no_of_weekenddays)
    @transaction.discounts = @product.discount_by_days(@transaction.duration_days, params[:operator_type].to_i, @no_of_weekenddays)
    @transaction.rent_with_discount = @product.price_with_discount(@transaction.duration_days, params[:operator_type].to_i, @no_of_weekenddays)
    @transaction.tax = @product.tax_amount(@transaction.duration_days, params[:operator_type].to_i, @no_of_weekenddays)
    @transaction.refundable_security_deposit = @product.security_deposit
    @transaction.amount = @product.calculate_price(@transaction.duration_days, params[:operator_type].to_i, @no_of_weekenddays)
    ###############
    @transaction.status = Transaction::TRANSACTION_STATUS[0][1]
    if @transaction.save
      current_user.send_message([@transaction, @product.user], params[:message], "Request for #{@product.title}")
      TransactionMailer.order_request(@transaction, params[:message]).deliver_now
      params = {
        'src' => "Cocociti",
        'dst' => "+919037267357",
        'text' => "Request has been sent to Item owner successfully. Please visit your Dashboard --> Booking Requests for updates. "
      }
      @transaction.send_sms(params)
      flash[:success] = "Request for #{@product.title} has been successfully sent to Item owner. You will receive a mail upon approval from Item Owner. You can also check the status in 'Booking Requests' tab."
      redirect_to dashboard_profiles_path
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
    @transaction.non_coco_operator = params[:non_coco_operator]
    @transaction.startdate = params[:non_coco_start_date]
    @transaction.enddate = params[:non_coco_end_date]
    @transaction.operator_type = Product::OPERATOR_TYPE[0][1]
    @transaction.product = @product
    @transaction.amount = 0
    @transaction.status = Transaction::TRANSACTION_STATUS[5][1]
    if @transaction.save
      flash[:notice] = "Booking done successfully."
      redirect_to :back
      return
    end
  end

  def delete_non_coco
    if @transaction.destroy
      flash[:notice] = "Booking deleted successfully."
      redirect_to :back
      return
    end
  end

  def checkout
    @product = @transaction.product
    if Rails.env.development?
      @amount=1
      @return_url=GLOBAL_VARIABLES[:transaction_return_url]
    elsif Rails.env.production?
      @amount = @transaction.amount
      #@amount=1
      @return_url=GLOBAL_VARIABLES[:transaction_return_url]
    end
    #@notifyUrl=""
    @address = current_user.address || current_user.copy_address!
    @transaction.generate_txnid!
  end

  def check_status_and_save_address_of_transaction
    error_messages = []
    error_messages << "Sorry, you cannot proceed with the operation." unless @transaction.coco_transaction_id == params[:mid]
    error_messages << "Sorry, you cannot proceed with the operation. The booking has expired." if @transaction.expired?
    @address = current_user.address
    @address.first_name = params[:first_name]
    @address.last_name = params[:last_name]
    @address.address1 = params[:address1]
    @address.address2 = params[:address2]
    @address.city = params[:city]
    @address.zip = params[:zip]
    @address.state = params[:state]
    @address.mobile = params[:mobile]
    @address.email = params[:email]

    @address.valid?

    unless @address.errors.full_messages.blank?
      error_messages << @address.errors.full_messages.join("</li><li>")
    end
    unless error_messages.blank?
      render json: {errors: error_messages}
    else
      @address.save
      render json: {errors: ""}
    end

  end

  def accept
    @transaction.accept!
    flash[:success] = "Request accepted successfully."
    redirect_to message_path(@transaction)
  end

  def deny
    @transaction.deny!
    flash[:success] = "Request denied successfully."
    redirect_to message_path(@transaction)
  end

  def callback
    id = params["TxId"]
    @transaction = current_user.transactions.find_by_coco_transaction_id id
    @product = @transaction.product
    @secret_key = CITRUS_CONFIG[:secret_key]

    @verification_data = params["TxId"]\
          + params["TxStatus"] \
          + params["amount"]\
          + params["pgTxnNo"]\
          + params["issuerRefNo"]\
          + params["authIdCode"]\
          + params["firstName"]\
          + params["lastName"]\
          + params["pgRespCode"]\
          + params["addressZip"]
    @signature=Transaction.hmac_sha1(@verification_data,@secret_key)
    logger.info '*****************'
    logger.info @verification_data
    logger.info @signature
    logger.info params["signature"]
    logger.info '*****************'
    if @signature == params["signature"]
      if params["TxStatus"] == Transaction::PAYMENT_GATEWAY_STATUS[0]
        @transaction.paid!(params["transactionId"], params["amount"])
        render :thankyou
      else
        TransactionMailer.fail(@transaction, params["TxMsg"]).deliver_now
        msg = params["TxMsg"]
        params = {
          'src' => "Cocociti",
        	'dst' => "+919037267357",
        	'text' => "Sorry, Your payment failed. #{msg}"
        }
        @transaction.send_sms(params)
        flash[:alert] = params["TxMsg"]
        redirect_to checkout_transaction_path(@transaction)
      end
    else
      message = "Signaure Verification failed. Please try again."
      flash[:alert] = message
      TransactionMailer.fail(@transaction, message).deliver_now
      params = {
        'src' => "Cocociti",
        'dst' => "+919037267357",
        'text' => "Sorry, Your payment failed as signaure Verification failed. Please try again."
      }
      @transaction.send_sms(params)
      redirect_to checkout_transaction_path(@transaction)
    end
  end

  private

  def set_product
    @product = Product.friendly.find params[:id]
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

  def check_session_value_and_past_dates_and_operator_type
    if session[:start_date_time].blank? || session[:end_date_time].blank?
      flash[:danger] = "Please select Pick up Date and Drop off Date in search bar in header to know the availability."
      redirect_to user_product_path(@product.id)
      return
    end
    if session[:start_date_time].in_time_zone("Kolkata") < Time.now.in_time_zone("Kolkata") || session[:end_date_time].in_time_zone("Kolkata") < Time.now.in_time_zone("Kolkata")
      flash[:danger] = "Invalid date range. Cannot book for past dates."
      redirect_to user_product_path(@product.id)
      return
    end
    params[:operator_type] = Product::OPERATOR_TYPE[0][1] if params[:operator_type].blank? || (params[:operator_type] != Product::OPERATOR_TYPE[1][1])
    params[:operator_type] = Product::OPERATOR_TYPE[1][1] if @product.operator_type == Product::OPERATOR_TYPE[1][1]
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
        redirect_to user_product_path(@product.id)
        return
      end
    else
      @product.transactions.renting.each do |transaction|
        transaction_start_date_time =  transaction.startdate - GLOBAL_VARIABLES[:buffer_time_of_transaction].hour
        transaction_end_date_time =  transaction.enddate + GLOBAL_VARIABLES[:buffer_time_of_transaction].hour
        if @product.enabled_days.include?("#{search_start_day}") && @product.enabled_days.include?("#{search_end_day}") && @product.enabled_hours.include?("#{search_start_time}") && @product.enabled_hours.include?("#{search_end_time}") && ( ((search_start_date_time > transaction_end_date_time) && (search_end_date_time > transaction_end_date_time)) || ((search_start_date_time < transaction_start_date_time) && (search_end_date_time < transaction_start_date_time)) )
        else
          flash[:danger] = "Sorry, Item is not available for the selected dates."
          redirect_to user_product_path(@product.id)
          return
        end
      end
    end
  end

  def product_availability_for_accepted
    if @transaction.accepted?
      search_start_day = @transaction.startdate.wday
      search_start_time = @transaction.startdate.strftime("%H:%M")
      search_end_day = @transaction.enddate.wday
      search_end_time = @transaction.enddate.strftime("%H:%M")

      search_start_date_time = @transaction.startdate
      earch_end_date_time = @transaction.enddate

      @product = @transaction.product

      if @product.transactions.renting.blank?
        if @product.enabled_days.include?("#{search_start_day}") && @product.enabled_days.include?("#{search_end_day}") && @product.enabled_hours.include?("#{search_start_time}") && @product.enabled_hours.include?("#{search_end_time}")
        else
          flash[:danger] = "Sorry, Item is not available for the selected dates."
          redirect_to user_product_path(@product.id)
          return
        end
      else
        @product.transactions.renting.each do |transaction|
          transaction_start_date_time =  transaction.startdate - GLOBAL_VARIABLES[:buffer_time_of_transaction].hour
          transaction_end_date_time =  transaction.enddate + GLOBAL_VARIABLES[:buffer_time_of_transaction].hour
          if @product.enabled_days.include?("#{search_start_day}") && @product.enabled_days.include?("#{search_end_day}") && @product.enabled_hours.include?("#{search_start_time}") && @product.enabled_hours.include?("#{search_end_time}") && ( ((search_start_date_time > transaction_end_date_time) && (search_end_date_time > transaction_end_date_time)) || ((search_start_date_time < transaction_start_date_time) && (search_end_date_time < transaction_start_date_time)) )
          else
            flash[:danger] = "Sorry, Item is not available for the selected dates."
            redirect_to user_product_path(@product.id)
            return
          end
        end
      end
    end
  end

  def basic_checks_before_checkout
    unless @transaction.user == current_user
      flash[:danger] = "Sorry, You can't execute this action"
      redirect_to root_path
      return
    end
    if @transaction.expired? || @transaction.paid? || @transaction.requesting? || @transaction.non_coco_booking? || @transaction.denied?
      flash[:danger] = "Sorry, You cannot access this page as the booking is invalid."
      redirect_to root_path
      return
    end
    if @transaction.past?
      flash[:danger] = "Invalid date range. Cannot book for past dates."
      redirect_to root_path
      return
    end
  end

end
