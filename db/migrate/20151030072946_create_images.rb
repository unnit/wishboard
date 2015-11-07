class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.integer :owner_id
      t.string :owner_type
      t.string :file

      t.timestamps null: false
    end

    Product.all.each do |product|
      product.old_images.each do |url|
        image = Image.new
        image.owner = product
        image.remote_file_url = url
        image.save
        p image.errors.full_messages
      end
    end
  end
end
