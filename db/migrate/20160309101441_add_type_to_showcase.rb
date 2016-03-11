class AddTypeToShowcase < ActiveRecord::Migration
  def change
	add_column :showcases, :showcase_type, :integer
  end
end
