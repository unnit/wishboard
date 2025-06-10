class ChangeTechSpecColumn < ActiveRecord::Migration[7.2]
  def change
    change_column :products, :tech_spec, :text
  end
end
