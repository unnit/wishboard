class CreateGiveaways < ActiveRecord::Migration
  def change
    create_table :giveaways do |t|
      t.string :name
      t.text :description
      t.integer :user_id
      t.string :image
      t.boolean :approved, default: false
      t.timestamps null: false
    end
  end
end
