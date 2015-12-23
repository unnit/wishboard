class TransactionMailer < ApplicationMailer
  default bcc: "#{GLOBAL_VARIABLES[:manager_email_id_1]},#{GLOBAL_VARIABLES[:manager_email_id_2]}"
  #to renter
  def accept(transaction)
    @transaction = transaction
    @product = transaction.product
    @user = transaction.user
    @owner = @product.user
    mail to: @user.email, subject: "Your order request is accepted"
  end

  def deny(transaction)
    @transaction = transaction
    @product = transaction.product
    @user = transaction.user
    @owner = @product.user
    mail to: @user.email, subject: "Your booking request is denied"
  end

  def fail(transaction, message)
    @transaction = transaction
    @product = transaction.product
    @user = transaction.user
    @owner = @product.user
    @message = message
    mail to: @user.email, subject: @message
  end

  def paid(transaction)
    @transaction = transaction
    @product = transaction.product
    @user = transaction.user
    @owner = @product.user
    mail to: @user.email, subject: "Booking successful on Cocociti for #{@product.title}"
  end

  #to owner
  def order_request(transaction, message)
    @transaction = transaction
    @product = transaction.product
    @user = transaction.user
    @owner = @product.user
    @message = message
    mail to: @owner.email, subject: "Rent request received for #{@product.title}, accept immediately."
  end

  def booking_done(transaction)
    @transaction = transaction
    @product = transaction.product
    @user = transaction.user
    @owner = @product.user
    mail to: @owner.email, subject: "Booking successful on Cocociti for #{@product.title}"
  end

end
