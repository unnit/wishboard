namespace :coco_tasks do
  task update_products_internal_id_via_backend: :environment do
    require 'csv'
    #filename = "#{Rails.root}/lib/madiwala-upload.csv"
    filename = "#{Rails.root}/lib/rentnzip-upload.csv"
    CSV.foreach(filename, headers: true) do |row|
      product = Product.find_by_id row[0]
      product.update_column :internal_id, row[2]
    end
  end

  task add_pickup_address: :environment do
    user_ids = Address.uniq.pluck(:user_id)
    user_ids.each do |id|
      user = User.find_by_id id
      address = user.addresses.delivery.first
      @address = Address.new
      @address.user = user
      @address.first_name = user.profile.first_name
      @address.last_name = user.profile.last_name
      @address.email = user.email
      @address.mobile = user.profile.phone
      @address.address1 = address.address1
      @address.address2 = address.address2
      @address.landmark = address.landmark
      @address.city = address.city
      @address.zip = address.zip
      @address.state = address.state
      @address.address_type = Address::ADDRESS_TYPES[1][1]
      @address.address_mandatory = "yes"
      @address.save
    end
  end

  task add_products_via_backend: :environment do
    sample_product = Product.find_by_id
    product = Product.new
    product.user_id = sample_product.user_id
    product.title = sample_product.title
    product.category_id = sample_product.category_id
    product.price = sample_product.price
    product.tax = sample_product.tax
    product.security_deposit = sample_product.security_deposit
    product.operator_type = sample_product.operator_type
    product.operator_price = sample_product.operator_price
    product.discount_3 = sample_product.discount_3
    product.discount_10 = sample_product.discount_10
    product.discount_20 = sample_product.discount_20
    product.discount_30 = sample_product.discount_30
    product.discount_90 = sample_product.discount_90
    product.available = sample_product.available
    product.description = sample_product.description
    product.owner_type = sample_product.owner_type
    product.product_condition = sample_product.product_condition
    product.tech_spec = sample_product.tech_spec
    product.billing_type = sample_product.billing_type
    product.terms_and_conditions = sample_product.terms_and_conditions
    product.year_of_manufacture = sample_product.year_of_manufacture
    product.image_1 = sample_product.image_1
    product.doc_requirement = sample_product.doc_requirement
    if product.save
      product.reload
      location = location.new
      location.locatable_id = product.id
      location.locatable_type = "Product"
      location.name = sample_product.location.name
      location.save
      @product.update_parent_category!
      @product.location.update_lat_lng
    end
  end

  task listing_to_showcase: :environment do
    @products = Product.all.order(:created_at)
    i = 0
    @products.each do |product|
      @showcase = Showcase.new
      @showcase.user = product.user
      @showcase.product = product
      @showcase.description = product.description
      @showcase.title = product.title
      @showcase.year = product.year_of_manufacture
      @showcase.image = product.image.filename
      @showcase.showcase_type = Showcase::SHOWCASE_VALUES[0]
      location = Location.new
      location.name = product.location.name
      if @showcase.save
        location.locatable_id = @showcase.id
        location.locatable_type = 'Showcase'
        location.save
        i+=1
      end
      puts i
    end
  end

  task create_wallet_for_all_users: :environment do
    profiles = Profile.all
    profiles.each do |profile|
      wallet = Wallet.new
      wallet.user = profile.user
      wallet.save
    end
  end

  task set_invite_code_for_all_users: :environment do
    profiles = Profile.all
    profiles.each do |profile|
      user = profile.user
      user.invite_code = user.generate_invite_code
      user.save
    end
  end

end
