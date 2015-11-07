class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.integer :user_id
      t.string :first_name
      t.string :last_name
      t.string :location
      t.string :image
      t.string :phone
      t.text :about

      t.timestamps null: false
    end
    add_index :profiles, :user_id
  end
end
