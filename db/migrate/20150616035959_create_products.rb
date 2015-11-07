class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.belongs_to :category, index: true, foreign_key: true
      t.string :listing_type
      t.string :title
      t.decimal :price
      t.text :description
      t.string :owner_type
      t.string :product_condition
      t.string :tech_spec
      t.decimal :weekly_rent
      t.decimal :monthly_rent
      t.decimal :security_deposit
      t.string :terms_and_conditions
      t.integer :year_of_manufacture
      t.string :doc_requirement
      t.decimal :replacement_cost
      t.string :location
      t.string :image_1
      t.string :image_2
      t.string :image_3
      t.string :slug

      t.timestamps null: false
    end
  end
end
