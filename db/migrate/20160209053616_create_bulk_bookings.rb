class CreateBulkBookings < ActiveRecord::Migration[7.2]
  def change
    create_table :bulk_bookings do |t|
      t.string :email
      t.string :mobile
      t.text :message
      t.timestamps null: false
    end
  end
end
