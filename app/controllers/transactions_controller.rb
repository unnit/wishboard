class TransactionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:callback]
  before_filter :authenticate_user!
  before_filter :set_transaction, only: [:accept, :deny, :checkout, :delete_non_coco]
  before_filter :check_product_owner, only: [:accept, :deny, :delete_non_coco]
  before_filter :set_product, only: [:new, :create, :non_coco]
  before_filter :check_product_availability, only: [:new, :create]
  before_filter :check_past_dates_and_operator_type, only: [:new, :create]
  before_filter :product_availability_for_accepted, only: [:checkout]
  before_filter :basic_checks_before_checkout, only: [:checkout]

  def new
    @transaction = @product.transactions.build(startdate: session[:start_date_time], enddate: session[:end_date_time], operator_type: params[:operator_type])
    @transaction.user = current_user
    if @transaction.valid?
      @address = current_user.address || current_user.copy_address!
      if @product.owner_type == Product::OWNER_TYPE[0][1]
        @transaction.status = Transaction::TRANSACTION_STATUS[1][1]
        @transaction.amount = @product.calculate_price(@transaction.duration_days, params[:operator_type])
        @transaction.save
        @transaction.generate_txnid!
        #TransactionsResetJob.set(wait: 10.minutes).perform_later
        redirect_to checkout_transaction_path(@transaction)
      end
    else
      flash[:danger] = @transaction.errors.full_messages.first
      redirect_to user_product_path(@product)
    end
  end

  def create
    @transaction = Transaction.new
    @transaction.user = current_user
    @transaction.startdate = session[:start_date_time]
    @transaction.enddate = session[:end_date_time]
    @transaction.operator_type = params[:operator_type]
    @transaction.product = @product
    @transaction.amount = @product.calculate_price(@transaction.duration_days, params[:operator_type])
    @transaction.status = Transaction::TRANSACTION_STATUS[0][1]
    if @transaction.save
      @transaction.generate_txnid!
      current_user.send_message([@transaction, @product.user], params[:message], "Request for #{@product.title}")
      TransactionMailer.order_request(@transaction, params[:message]).deliver_now
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
    unless @transaction.user == current_user
      flash[:danger] = "Sorry, You can't execute this action"
      redirect_to root_path
      return
    end
    if @transaction.status == Transaction::TRANSACTION_STATUS[4][1]
      flash[:danger] = "Sorry, This transaction got expired, Please select the product again."
      redirect_to root_path
      return
    end
    #if @transaction.startdate < Time.now.in_time_zone("Kolkata") || @transaction.enddate < Time.now.in_time_zone("Kolkata")
    #  flash[:danger] = "Invalid date range. Cannot book for past dates."
    #  redirect_to root_path
    #  return
    #end
    logger.info '*****************'
    logger.info @transaction.security_signature
    logger.info '*****************'
    @product = @transaction.product
    @amount=1
    @return_url="https://localhost/transactions/callback"
    #@notifyUrl="http://www.yourwebsite.com/notifyResponsePage.php"
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
    id = params["TxId"]
    @transaction = current_user.transactions.find_by_coco_transaction_id id
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
    #render :text=>@verification_data
    #require 'json'
    if @signature == params["signature"]
       #@json_object = @data.to_json
       # take some actions
       @transaction.paid!(params["transactionId"], params["amount"])
       @address = current_user.address
       @address.update_columns first_name: params["firstName"], last_name: params["lastName"], address1: params["addressStreet1"], address2: params["addressStreet2"], city: params["addressCity"], zip: params["addressZip"], state: params["addressState"], country: params["addressCountry"], mobile: params["mobileNo"], email: params["email"]
       render :thankyou

    else

       #@response_data = {"Error" => "Transaction Failed","Reason" => "Signature Verification Failed"}
       #@json_object=@response_data.to_json
       TransactionMailer.fail(@transaction, params["TxMsg"]).deliver_now
       redirect_to checkout_transaction_path(@transaction)
       # take some actions

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

  def check_past_dates_and_operator_type
    if session[:start_date_time].in_time_zone("Kolkata") < Time.now.in_time_zone("Kolkata") || session[:end_date_time].in_time_zone("Kolkata") < Time.now.in_time_zone("Kolkata")
      flash[:danger] = "Invalid date range. Cannot book for past dates."
      redirect_to user_product_path(@product)
      return
    end
    params[:operator_type] = Product::OPERATOR_TYPE[0][1] if params[:operator_type].blank?
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
        redirect_to user_product_path(@product)
        return
      end
    else
      @product.transactions.renting.each do |transaction|
        transaction_start_date_time =  transaction.startdate - 1.hour
        transaction_end_date_time =  transaction.enddate + 1.hour
        if @product.enabled_days.include?("#{search_start_day}") && @product.enabled_days.include?("#{search_end_day}") && @product.enabled_hours.include?("#{search_start_time}") && @product.enabled_hours.include?("#{search_end_time}") && ( ((search_start_date_time > transaction_end_date_time) && (search_end_date_time > transaction_end_date_time)) || ((search_start_date_time < transaction_start_date_time) && (search_end_date_time < transaction_start_date_time)) )
        else
          flash[:danger] = "Sorry, Item is not available for the selected dates."
          redirect_to user_product_path(@product)
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

      if @product.transactions.renting.blank?
        if @product.enabled_days.include?("#{search_start_day}") && @product.enabled_days.include?("#{search_end_day}") && @product.enabled_hours.include?("#{search_start_time}") && @product.enabled_hours.include?("#{search_end_time}")
        else
          flash[:danger] = "Sorry, Item is not available for the selected dates."
          redirect_to user_product_path(@product)
          return
        end
      else
        @product.transactions.renting.each do |transaction|
          transaction_start_date_time =  transaction.startdate - 1.hour
          transaction_end_date_time =  transaction.enddate + 1.hour
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

  def basic_checks_before_checkout
    unless @transaction.user == current_user
      flash[:danger] = "Sorry, You can't execute this action"
      redirect_to root_path
      return
    end
    if @transaction.expired?
      flash[:danger] = "Sorry, This transaction got expired, Please select the product again."
      redirect_to root_path
      return
    end
    if @transaction.paid?
      flash[:danger] = "Sorry, You cannot access this page."
      redirect_to root_path
      return
    end
  end

end
