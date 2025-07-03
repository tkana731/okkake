class AddLotteryAnnouncementTimeToReservations < ActiveRecord::Migration[8.0]
  def change
    add_column :reservations, :lottery_announcement_time, :datetime
  end
end
