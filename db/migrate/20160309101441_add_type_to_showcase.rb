class AddTypeToShowcase < ActiveRecord::Migration[7.2]
  def change
	add_column :showcases, :showcase_type, :integer
  end
end
