class AddBusinessTypeToProfiles < ActiveRecord::Migration
  def change
	add_column :profiles, :business_type, :integer
  end
end
