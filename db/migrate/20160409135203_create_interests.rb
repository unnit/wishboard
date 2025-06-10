class CreateInterests < ActiveRecord::Migration[7.2]
  def change
    create_table :interests do |t|
      t.integer :user_id, index: true
      t.integer :tag_id, index: true
      t.boolean :active, default: true, index: true
      t.timestamps null: false
    end
    add_index :interests, [:user_id, :tag_id], unique: true
  end
end
