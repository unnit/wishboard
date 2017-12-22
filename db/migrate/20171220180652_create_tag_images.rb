class CreateTagImages < ActiveRecord::Migration[5.0]
  def change
    create_table :tag_images do |t|
      t.belongs_to :tag, index: true
      t.string :image
      t.timestamps
    end
  end
end
