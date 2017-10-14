class AdminMailer < ApplicationMailer
  default bcc: "#{GLOBAL_VARIABLES[:manager_email_id_1]}"
  def new_user(user)
    @user = user
    mail to: GLOBAL_VARIABLES[:notification_mail], subject: "New User: #{user.email} has joined cocociti"
  end

  def new_product(product)
    @product = product
    mail to: GLOBAL_VARIABLES[:notification_mail], subject: "New Product: #{product.title}"
  end

  def update_product(product)
    @product = product
    mail to: GLOBAL_VARIABLES[:notification_mail], subject: "Product Updated: #{product.title}"
  end

  def new_showcase(showcase)
    @showcase = showcase
    mail to: GLOBAL_VARIABLES[:manager_email_id_2], subject: "New Wish: #{showcase.title}, Owner: #{showcase.user.name}"
  end

end
