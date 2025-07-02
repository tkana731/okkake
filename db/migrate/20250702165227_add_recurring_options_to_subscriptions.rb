class AddRecurringOptionsToSubscriptions < ActiveRecord::Migration[8.0]
  def change
    # より詳細な繰り返し間隔指定のため
    add_column :subscriptions, :billing_cycle_type, :string, null: false, default: 'monthly', comment: '繰り返し間隔タイプ（daily, weekdays, weekly, biweekly, triweekly, monthly, bimonthly, trimonthly, quarterly, semi_annual, yearly）'
    
    # カスタム間隔（2-5ヶ月など）
    add_column :subscriptions, :custom_interval, :integer, default: 1, comment: 'カスタム間隔数（例：2ヶ月ごとの場合は2）'
    
    # 平日のみフラグ
    add_column :subscriptions, :weekdays_only, :boolean, default: false, null: false, comment: '平日（月-金）のみ繰り返すかどうか'
    
    # 祝日調整オプション
    add_column :subscriptions, :holiday_adjustment, :string, default: 'none', comment: '祝日調整（none: 調整なし、before: 直前の平日、after: 直後の平日）'
  end
end
