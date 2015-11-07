class ChangeTechSpecColumn < ActiveRecord::Migration
  def change
    change_column :products, :tech_spec, :text
  end
end
