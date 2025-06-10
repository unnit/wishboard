class AddActiveToRelationshipsAndWows < ActiveRecord::Migration[7.2]
  def change
    add_column :relationships, :active, :boolean, default: true
    add_column :wows, :active, :boolean, default: true
  end
end
