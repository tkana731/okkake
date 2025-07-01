class CreateSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.decimal :amount
      t.string :billing_cycle
      t.date :next_billing_date
      t.string :status
      t.text :memo

      t.timestamps
    end
  end
end
