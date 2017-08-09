class CreateFundreceivedNotifications < ActiveRecord::Migration[5.0]
  def change
    create_table :fundreceived_notifications do |t|
      t.integer :user_id
      t.integer :cocotransfer_id
      t.boolean :active, default: true
      t.boolean :checked, default: false
      t.boolean :mailed, default: false

      t.timestamps
    end
  end
end
