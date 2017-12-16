class CocotransfersController < ApplicationController
  before_action :set_cocotransfer, only: [:show, :checkout, :transfer_success]
  before_action :set_verification_data, only:[:callback]
  skip_before_action :verify_authenticity_token, only: [:callback]

  def get_payment_details
    @cocotransfer = Cocotransfer.find_by_id(params[:cocotransfer][:id])
    @cocotransfer.assign_attributes(cocotransfer_params)
    @cocotransfer.assign_attributes(fullfillment_contributer: current_user)
    return redirect_to new_cocotransfer_path(amount: @cocotransfer.amount,  showcase_id: @cocotransfer.showcase_id) if @cocotransfer.paid?
    changed = @cocotransfer.changed?
    changed_attributes = @cocotransfer.changed
    if @cocotransfer.update_attributes(cocotransfer_params)
      @cocotransfer.generate_txnid!
      @cocotransfer.reload
      render json: {cocotransfer: @cocotransfer, success: true, changed: changed, changed_attributes: changed_attributes, security_signature: @cocotransfer.security_signature, return_url: @cocotransfer.return_url}
    else
      error_messages = @cocotransfer.errors.full_messages.join(", ")
      render json: {cocotransfer: @cocotransfer, success: false, error_messages: error_messages }
    end
  end

  def new
    @cocotransfer = Cocotransfer.new
    @cocotransfer.transferable_id = params[:transferable_id]
    @cocotransfer.transferable_type = params[:transferable_type]
    if current_user
      @cocotransfer.use_wallet_amount = true
    else
      @cocotransfer.use_wallet_amount = false
      @cocotransfer.wallet_amount = 0
    end
    @showcase = Showcase.find_by_id(params[:transferable_id]) if @cocotransfer.showcase_transfer?
    @receiver = User.find_by_id(params[:transferable_id]) if @cocotransfer.profile_transfer?
    #vaild_showcase_transfer = (@showcase && @showcase.is_for_raising_fund? && !@showcase.is_admin_disabled? && !@showcase.campaign_ended?)
    vaild_showcase_transfer = (@showcase && @showcase.can_accept_gift?)
    valid_profile_transfer = @receiver && @receiver.can_accept_gift?
    # @cocotransfer.transferable_type = valid_profile_transfer ? Cocotransfer::TRANSFER_TYPE[1][1] : Cocotransfer::TRANSFER_TYPE[0][1]
    if valid_profile_transfer || vaild_showcase_transfer
      assign_coco_attributes
    else
      redirect_to root_path
    end
  end

  def create
    @cocotransfer = Cocotransfer.new(cocotransfer_params)
    @cocotransfer.transaction_status = Transaction::TRANSACTION_STATUS[1][1]
    @cocotransfer.fullfillment_contributer = current_user
    unless current_user
      @cocotransfer.use_wallet_amount = false
      @cocotransfer.wallet_amount = 0
    end
    if @cocotransfer.save
      @cocotransfer.generate_txnid!
      if @cocotransfer.is_only_wallet?
       return process_wallet_payment("html")
      else
       return redirect_to checkout_cocotransfer_path(@cocotransfer.slug)
      end
      # return redirect_to checkout_cocotransfer_path(@cocotransfer.slug)
    else
      flash[:alert] = @cocotransfer.errors.full_messages.join(", ")
      render :new
    end
  end

  def checkout
    return redirect_to new_cocotransfer_path(amount: (@cocotransfer.wallet_amount.to_i + @cocotransfer.amount.to_i), transferable_type: @cocotransfer.transferable_type, transferable_id: @cocotransfer.transferable_id ) if @cocotransfer.paid?
    @cocotransfer.generate_txnid!
  end

  def update
    @cocotransfer = Cocotransfer.find_by_id(params[:id])
    unless @cocotransfer.paid?
      if @cocotransfer.update_attributes(cocotransfer_params)
        @cocotransfer.generate_txnid!
        if @cocotransfer.is_only_wallet?
         return process_wallet_payment("js")
        else
          render json: {cocotransfer: @cocotransfer, security_signature: @cocotransfer.security_signature, return_url: @cocotransfer.return_url, success: true, total_amount: @cocotransfer.total_amount}
        end
      else
        error_messages = @cocotransfer.errors.full_messages.join(", ")
        render json: {cocotransfer: @cocotransfer, success: false, error_messages: error_messages }
      end
    end
  end


  def transfer_success
     render :payment_success
  end

  def callback
    @cocotransfer = Cocotransfer.find_by_txnid params["TxId"]
    save_txdetails
    # @showcase = @cocotransfer.showcase
    @secret_key = CITRUS_CONFIG[:secret_key]
    @signature= @cocotransfer.hmac_sha1(@verification_data, @secret_key)
    log_transaction_response
    handle_invalid_signature if @signature != params["signature"]
    if params["TxStatus"] == Transaction::PAYMENT_GATEWAY_STATUS[0]
      available_wallet_amount = @cocotransfer.fullfillment_contributer.try(:total_profile_withdraw_available_amount).to_i
      wallet_amount = ((@cocotransfer.wallet_amount.to_i > 0)  && available_wallet_amount < @cocotransfer.wallet_amount.to_i ) ? available_wallet_amount : @cocotransfer.wallet_amount
      @cocotransfer.update_columns(transaction_status: Transaction::TRANSACTION_STATUS[2][1].to_i, amount: params[:amount], wallet_amount: wallet_amount) unless @cocotransfer.paid?
      @cocotransfer.paid_callbacks!
      redirect_to transfer_success_cocotransfer_path(@cocotransfer.slug)
      # render :payment_success
    else
      #available_wallet_amount = @cocotransfer.fullfillment_contributer.try(:total_profile_withdraw_available_amount).to_i
      #wallet_amount = ((@cocotransfer.wallet_amount.to_i > 0)  && available_wallet_amount < @cocotransfer.wallet_amount.to_i ) ? available_wallet_amount : @cocotransfer.wallet_amount
      #unless @cocotransfer.paid?
       #@cocotransfer.update_columns(transaction_status: Transaction::TRANSACTION_STATUS[2][1].to_i, amount: params[:amount], wallet_amount: wallet_amount) unless @cocotransfer.paid?
       #@cocotransfer.paid_callbacks!
      #end
      #redirect_to transfer_success_cocotransfer_path(@cocotransfer.slug)
      @cocotransfer.deliver_failed_transaction(params["TxMsg"])
      flash[:alert] = "#{params["TxMsg"]}"
      redirect_to checkout_cocotransfer_path(@cocotransfer.slug)
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
    @cocotransfer = Cocotransfer.find_by_slug(params[:id])
  end

  def cocotransfer_params
    params.require(:cocotransfer).permit(:transferable_id, :amount, :donor_name, :email, :hide_identity, :phonecode, :phone, :transferable_type, :user_id, :wallet_amount, :use_wallet_amount)
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
    redirect_to checkout_cocotransfer_path(@cocotransfer.slug) and return true
  end

  def initiate_new_checkout
    @old_coco_transfer =  @cocotransfer
    @cocotransfer = Cocotransfer.new
    @cocotransfer.attributes = @old_coco_transfer.attributes.symbolize_keys.slice(:transferable_id, :amount, :email, :donor_name, :phonecode, :phone, :transferable_type, :use_wallet_amount, :wallet_amount)
    if @cocotransfer.save
      @cocotransfer.generate_txnid!
      return redirect_to checkout_cocotransfer_path(@cocotransfer.slug)
    else
      flash[:alert] = @cocotransfer.errors.full_messages.join(", ")
      render :new
    end
    redirect_to checkout_cocotransfer_path(@cocotransfer.slug)
  end

  def redirect_to_new_cocotransfer
  end

  def assign_coco_attributes
    set_wallet_and_online_amount
    @cocotransfer.donor_name = !params[:donor_name].blank? ?  params[:donor_name] : current_user.try(:name)
    @cocotransfer.email = !params[:email].blank? ?  params[:email] : current_user.try(:email)
    @cocotransfer.phonecode = params[:phonecode].blank? ?  params[:phonecode] : current_user.try(:profile).try(:phonecode)
    @cocotransfer.phone = !params[:phone].blank? ?  params[:phone] : current_user.try(:profile).try(:phone)
  end


   def set_wallet_and_online_amount
     available_profile_amount  = current_user.try(:total_profile_withdraw_available_amount)
     if params[:gift_type] == "fullfill" && @cocotransfer.showcase_transfer? && @cocotransfer.transferable.can_be_fullfilled_at_once?
       total_amount = @cocotransfer.transferable.try(:fullfillment_at_once_amount).to_i
     else
       total_amount = !params[:amount].blank? && params[:amount].to_i > @cocotransfer.transferable.try(:min_gift_amount_allowed).to_i ? params[:amount].to_i : @cocotransfer.transferable.try(:min_gift_amount_allowed).to_i
     end
     @cocotransfer.wallet_amount = (available_profile_amount.to_i >= total_amount )? total_amount : available_profile_amount.to_i
     @cocotransfer.amount = (total_amount - @cocotransfer.wallet_amount.to_i)
   end

   def process_wallet_payment(response_format)
     @cocotransfer.update_columns(transaction_status: Transaction::TRANSACTION_STATUS[2][1].to_i, amount: 0) unless @cocotransfer.paid?
     @cocotransfer.paid_callbacks!
     if response_format == "html"
        redirect_to transfer_success_cocotransfer_path(@cocotransfer.slug) and return true
     else
       render js: "window.location = '#{transfer_success_cocotransfer_path(@cocotransfer.slug)}'"
       return true
     end
   end
end
