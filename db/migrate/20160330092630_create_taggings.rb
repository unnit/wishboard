class CreateTaggings < ActiveRecord::Migration
  def change
    create_table :taggings do |t|
      t.integer :showcase_id, index: true
      t.integer :tag_id, index: true
      t.timestamps null: false
    end
    add_index :taggings, [:showcase_id, :tag_id], unique: true
  end
end
