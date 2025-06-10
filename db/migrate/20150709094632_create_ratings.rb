class CreateRatings < ActiveRecord::Migration[7.2]
  def change
    create_table :ratings do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.belongs_to :product, index: true, foreign_key: true
      t.integer :value, default: 0

      t.timestamps null: false
    end
    add_column :products, :rate, :integer, default: 0
  end
end