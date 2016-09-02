class AddShareColumnsToShowcase < ActiveRecord::Migration
  def change
    add_column :showcases, :parent_id, :integer
    add_column :showcases, :grandparent_id, :integer
    add_index :showcases, :parent_id
    add_index :showcases, :grandparent_id
  end
end
