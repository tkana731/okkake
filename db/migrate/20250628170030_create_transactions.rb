class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.decimal :amount
      t.string :transaction_type
      t.date :transaction_date
      t.text :memo
      t.string :vendor
      t.integer :satisfaction_rating

      t.timestamps
    end
  end
end
