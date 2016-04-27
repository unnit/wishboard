class AddActiveToRelationshipsAndWows < ActiveRecord::Migration
  def change
    add_column :relationships, :active, :boolean, default: true
    add_column :wows, :active, :boolean, default: true
  end
end
