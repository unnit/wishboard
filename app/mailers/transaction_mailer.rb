class TransactionMailer < ApplicationMailer
  #to renter
  def accept(transaction)
    @transaction = transaction
    @product = transaction.product
    @user = transaction.user
    @owner = @product.user
    @base_url = "#{ActionMailer::Base.default_url_options[:host]}"
    mail to: @user.email, subject: "Your order request is accepted"
  end

  def deny(transaction)
    @transaction = transaction
    @product = transaction.product
    @user = transaction.user
    @owner = @product.user
    @base_url = "#{ActionMailer::Base.default_url_options[:host]}"
    mail to: @user.email, subject: "Your order request is denied"
  end

  def fail(transaction, message)
    @transaction = transaction
    @product = transaction.product
    @user = transaction.user
    @owner = @product.user
    @message = message
    @base_url = "#{ActionMailer::Base.default_url_options[:host]}"
    mail to: @user.email, subject: "Payment was unsuccessful"
  end

  def paid(transaction)
    @transaction = transaction
    @product = transaction.product
    @user = transaction.user
    @owner = @product.user
    @base_url = "#{ActionMailer::Base.default_url_options[:host]}"
    mail to: @user.email, subject: "Cocociti booking successful for #{@product.title}"
  end

  #to owner
  def order_request(transaction, message)
    @transaction = transaction
    @product = transaction.product
    @user = transaction.user
    @owner = @product.user
    @message = message
    @base_url = "#{ActionMailer::Base.default_url_options[:host]}"
    mail to: @owner.email, subject: "Rent request received for #{@product.title}, accept immediately."
  end

  def booking_done(transaction)
    @transaction = transaction
    @product = transaction.product
    @user = transaction.user
    @owner = @product.user
    @base_url = "#{ActionMailer::Base.default_url_options[:host]}"
    mail to: @owner.email, subject: "Cocociti booking successful for #{@product.title}"
  end

end
