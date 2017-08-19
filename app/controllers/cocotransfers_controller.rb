class CocotransfersController < ApplicationController
  before_action :set_cocotransfer, only: [:show, :checkout]
  before_action :set_verification_data, only:[:callback]
  skip_before_action :verify_authenticity_token, only: [:callback]

  def get_payment_details
  end

  def new
    @showcase = Showcase.find_by_id(params[:showcase_id])
    if @showcase.is_for_raising_fund? && !@showcase.is_admin_disabled?
      @cocotransfer = Cocotransfer.new
      @cocotransfer.showcase = @showcase
      assign_coco_attributes
    else
      redirect_to root_path
    end
  end

  def show
  end

  def checkout
    return initiate_new_checkout  if @cocotransfer.paid?
    @cocotransfer.generate_txnid!
    # render 'checkoutsimple' and return
  end

  def update
    @cocotransfer = Cocotransfer.find_by_id(params[:id])
    unless @cocotransfer.paid?
    if @cocotransfer.update_attributes(cocotransfer_params)
      @cocotransfer.generate_txnid!
      render json: {cocotransfer: @cocotransfer, security_signature: @cocotransfer.security_signature, return_url: @cocotransfer.return_url, success: true}
    else
      error_messages = @cocotransfer.errors.full_messages.join(", ")
      render json: {cocotransfer: @cocotransfer, success: false, error_messages: error_messages }
    end
     end
  end

  def create
    @cocotransfer = Cocotransfer.new(cocotransfer_params)
    @cocotransfer.transaction_status = Transaction::TRANSACTION_STATUS[1][1]
    @cocotransfer.fullfillment_contributer = current_user
    if @cocotransfer.save
      @cocotransfer.generate_txnid!
      return redirect_to checkout_cocotransfer_path(@cocotransfer)
    else
      flash[:alert] = @cocotransfer.errors.full_messages.join(", ")
      render :new
      # redirect_to new_cocotransfer_path(@cocotransfer, showcase_id: 3, amount: @cocotransfer.amount, email: @cocotransfer.email)
    end
  end

  def callback
    @cocotransfer = Cocotransfer.find_by_txnid params["TxId"]
    save_txdetails
    @showcase = @cocotransfer.showcase
    @secret_key = CITRUS_CONFIG[:secret_key]
    @signature= @cocotransfer.hmac_sha1(@verification_data,@secret_key)
    log_transaction_response
    handle_invalid_signature if @signature != params["signature"]
    if params["TxStatus"] == Transaction::PAYMENT_GATEWAY_STATUS[0]
      @cocotransfer.paid!(params["transactionId"], params["amount"])
      render :payment_success
    else
      ##### comment it after checking (test purpose only)
      @cocotransfer.paid!(params["transactionId"], params["amount"])
      render :payment_success
      ##### comment it after checking (test purpose only) uncomment below
      # @cocotransfer.deliver_failed_transaction(params["TxMsg"])
      # flash[:alert] = "#{params["TxMsg"]}"
      # redirect_to checkout_cocotransfer_path(@cocotransfer)
    end
  end



  private
  def save_txdetails
    unless Txdetail.find_by_tx_id params["TxId"]
      @txdetail= Txdetail.create(transaction_parameters)
      @txdetail.cocotransfer = @cocotransfer
      @txdetail.save
    end
  end


  def transaction_parameters
    params.permit("TxStatus", "TxId", "TxRefNo", "pgTxnNo", "pgRespCode", "TxMsg", "amount", "authIdCode", "issuerRefNo", "signature", "transactionId", "paymentMode", "TxGateway", "currency", "issuerCode", "firstName", "lastName", "email", "addressStreet1", "addressStreet2", "addressCity", "addressState", "addressCountry", "addressZip", "mobileNo", "isCOD", "txnDateTime", "impsMmid", "impsMobileNumber").map{|k, v| [k.underscore, v]}.to_h.symbolize_keys
  end

  def set_cocotransfer
    @cocotransfer = Cocotransfer.find(params[:id])
  end

  def cocotransfer_params
    params.require(:cocotransfer).permit(:showcase_id, :amount, :donor_name, :email, :hide_identity, :phonecode, :phone)
  end

  def log_transaction_response
    logger.info '*****************'
    logger.info @verification_data
    logger.info @signature
    logger.info params["signature"]
    logger.info '*****************'
  end

  def set_verification_data
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
  end

  def handle_invalid_signature
    @cocotransfer.deliver_signature_verification_failed
    flash[:alert] = "Signaure Verification failed. Please try again."
    redirect_to checkout_cocotransfer_path(@cocotransfer) and return true
  end

  def initiate_new_checkout
    @old_coco_transfer =  @cocotransfer
    @old_coco_transfer = Cocotransfer.last
    @cocotransfer = Cocotransfer.new
    @cocotransfer.attributes = @old_coco_transfer.attributes.symbolize_keys.slice(:showcase_id, :amount, :email, :donor_name, :phonecode, :phone)
    @cocotransfer.showcase_id = 644
    @cocotransfer.amount = 4000
    @cocotransfer.save
    redirect_to checkout_cocotransfer_path(@cocotransfer)
  end

  def assign_coco_attributes
    @cocotransfer.amount = !params[:amount].blank? && params[:amount].to_i > @showcase.try(:default_gift_amount).to_i ? params[:amount] : @showcase.try(:default_gift_amount).to_i
    @cocotransfer.donor_name = !params[:donor_name].blank? ?  params[:donor_name] : current_user.try(:name)
    @cocotransfer.email = !params[:email].blank? ?  params[:email] : current_user.try(:email)
    @cocotransfer.phonecode = params[:phonecode].blank? ?  params[:phonecode] : current_user.try(:profile).try(:phonecode)
    @cocotransfer.phone = !params[:phone].blank? ?  params[:phone] : current_user.try(:profile).try(:phone)
  end
end
