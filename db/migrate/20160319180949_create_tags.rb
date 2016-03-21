class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :name, index: true
      t.timestamps null: false
    end

    create_table :showcases_tags, id: false do |t|
      t.integer :showcase_id, index: true
      t.integer :tag_id, index: true
    end
  end
end
