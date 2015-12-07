class AddColumnsToAddressAndProfiles < ActiveRecord::Migration
  def change
    add_column :addresses, :landmark, :string
    add_column :profiles, :gender, :string
    add_column :profiles, :date_of_birth, :date
  end
end
