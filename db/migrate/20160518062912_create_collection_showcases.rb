class CreateCollectionShowcases < ActiveRecord::Migration[7.2]
  def change
    create_table :collection_showcases do |t|
      t.integer :collection_id
      t.integer :showcase_id
      t.timestamps null: false
    end
  end
end
