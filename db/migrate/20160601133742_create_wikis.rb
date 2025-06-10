class CreateWikis < ActiveRecord::Migration[7.2]
  def change
    create_table :wikis do |t|
      t.string :title
      t.text :description
      t.integer :user_id
      t.integer :position
      t.timestamps null: false
    end
    add_index :wikis, :user_id
  end
end
