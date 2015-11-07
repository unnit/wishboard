class TransactionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:callback]
  before_filter :authenticate_user!, except: [:get_price]
  before_filter :set_product, only: [:new, :create, :get_price]
  before_filter :set_transaction, only: [:accept, :deny]

  def checkout
    @transaction = current_user.transactions.find params[:id]
    @product = @transaction.product
    @transaction.amount
    @transaction.generate_txnid!
    @address = current_user.address || current_user.copy_address!
  end

  def get_price
    transaction = Transaction.new(user_id: 1, startdate: params[:startdate], enddate: params[:enddate], product_id: params[:product_id])
    
    unless transaction.valid?
      render json: {error: transaction.errors.full_messages.first}
    else
      days = transaction.duration_days
      pay_amount = @product.calculate_price(days, params[:operator_type])
      discount = @product.discount_by_days(days)
      tax = @product.tax_amount(days, params[:operator_type])
      sign = discount > 0 ? "-" : ""
      render json: {days: days,tax: tax, total_price: @product.price*days, pay_amount: pay_amount, discount: discount, sign: sign}
    end
  end

  def new
    @transaction = @product.transactions.build(startdate: params[:from], enddate: params[:to], operator_type: params[:operator_type])
    @transaction.user = current_user
    if @transaction.valid?
      if @product.owner_type == "Dealer/Agency"
        @transaction.status = "waiting_payment"
        @transaction.amount = @product.calculate_price(@transaction.duration_days, params[:operator_type])
        @transaction.save
        redirect_to checkout_transaction_path(@transaction)
      end
      @address = current_user.address || current_user.copy_address!
    else
      flash[:danger] = @transaction.errors.full_messages.first
      redirect_to user_product_path(@product.user.profile, @product)
    end
  end

  def accept
    @transaction.accept!
    redirect_to message_path(@transaction)
  end

  def deny
    @transaction.deny!
    redirect_to message_path(@transaction)
  end

  def create
    @transaction = current_user.transactions.build(transaction_params)
    @transaction.product = @product
    @transaction.amount = @product.calculate_price(@transaction.duration_days)
    @transaction.status = "requesting"

    if @transaction.save
      current_user.send_message([@transaction, @product.user], params[:message], "Request for #{@product.title}")
      TransactionMailer.order_request(@transaction, params[:message]).deliver

      redirect_to my_profile_profiles_path
    else
      flash[:danger] = @transaction.errors.full_messages.join("<br/>").html_safe
      render :new
    end
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
  def transaction_params
    params.require(:transaction).permit(:startdate, :enddate, :operator_type)
  end

  def set_product
    @product = Product.friendly.find params[:product_id]
  end

  def set_transaction
    @transaction = Transaction.find params[:id]
    unless @transaction.seller == current_user
      flash[:danger] = "You can't execute this action"
      redirect_to root_path
    end
  end
end
