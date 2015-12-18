namespace :coco_tasks do
  task add_products_via_backend: :environment do
    require 'csv'
    filename = "#{Rails.root}/lib/upload_products.csv"
    CSV.foreach(filename, headers: true) do |row|
      Product.create!(row.to_hash)
    end
  end
end
