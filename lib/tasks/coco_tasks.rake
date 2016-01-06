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

end
