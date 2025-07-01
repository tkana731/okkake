class AddReservationTypeToReservations < ActiveRecord::Migration[8.0]
  def change
    add_column :reservations, :reservation_type, :string, null: false, default: 'confirmed'
    add_index :reservations, :reservation_type
  end
end
