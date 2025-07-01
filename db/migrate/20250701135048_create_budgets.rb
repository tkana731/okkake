class CreateBudgets < ActiveRecord::Migration[8.0]
  def change
    create_table :budgets do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, default: 0.0, null: false
      t.decimal :spent, precision: 10, scale: 2, default: 0.0, null: false
      t.date :month, null: false
      t.references :category, foreign_key: true

      t.timestamps
    end

    add_index :budgets, [:user_id, :month, :category_id], unique: true
  end
end
