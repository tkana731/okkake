class AddUserIdToCategories < ActiveRecord::Migration[8.0]
  def change
    add_reference :categories, :user, null: true, foreign_key: true
  end
end
