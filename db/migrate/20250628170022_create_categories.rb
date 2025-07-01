class CreateCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :categories do |t|
      t.string :name
      t.string :icon
      t.string :color
      t.string :category_type
      t.integer :parent_id

      t.timestamps
    end
  end
end
