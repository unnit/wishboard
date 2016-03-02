class CreateShowcases < ActiveRecord::Migration
  def change
    create_table :showcases do |t|
      t.string :title
      t.string :description
      t.integer :year
      t.integer :user_id
      t.string :image
      t.timestamps null: false
    end
    add_index :showcases, :user_id
  end
end
