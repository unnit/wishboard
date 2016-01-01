class AddColumnTypeToAddresses < ActiveRecord::Migration
  def change
    add_column :addresses, :address_type, :integer
  end
end
