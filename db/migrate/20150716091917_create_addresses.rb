class CreateAddresses < ActiveRecord::Migration[7.2]
  def change
    create_table :addresses do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :mobile
      t.string :address1
      t.string :address2
      t.string :city
      t.string :zip
      t.string :state
      t.string :country

      t.timestamps null: false
    end
  end
end
