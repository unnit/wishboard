class CreateWows < ActiveRecord::Migration[7.2]
  def change
    create_table :wows do |t|
      t.integer :user_id
      t.integer :showcase_id
      t.timestamps null: false
    end
    add_index :wows, :user_id
    add_index :wows, :showcase_id
  end
end
