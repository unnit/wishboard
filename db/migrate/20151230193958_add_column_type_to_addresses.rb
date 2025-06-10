class AddColumnTypeToAddresses < ActiveRecord::Migration[7.2]
  def change
    add_column :addresses, :address_type, :integer
  end
end
