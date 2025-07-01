class CreateReservations < ActiveRecord::Migration[8.0]
  def change
    create_table :reservations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.decimal :total_amount
      t.decimal :paid_amount
      t.date :due_date
      t.string :status
      t.text :memo

      t.timestamps
    end
  end
end
