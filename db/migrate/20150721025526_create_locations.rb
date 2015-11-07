class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :name
      t.decimal :lat
      t.decimal :lng
      t.decimal :distance
      t.references :locatable, polymorphic: true, index: true

      t.timestamps null: false
    end
    remove_column :products, :location
    remove_column :profiles, :location
  end
end