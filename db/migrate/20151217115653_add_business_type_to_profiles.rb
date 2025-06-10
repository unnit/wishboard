class AddBusinessTypeToProfiles < ActiveRecord::Migration[7.2]
  def change
	add_column :profiles, :business_type, :integer
  end
end
