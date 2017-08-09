class CreateCocoMoneys < ActiveRecord::Migration[5.0]
  def change
    create_table :coco_moneys do |t|
      t.float :amount
      t.integer :to_user_id
      t.integer :from_user_id
      t.integer :showcase_id
      t.boolean :hide_identity
      t.boolean :active
      t.boolean :checked
      t.boolean :mailed

      t.timestamps
    end
  end
end
