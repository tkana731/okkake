class Subscription < ApplicationRecord
  # 関連付け
  belongs_to :user
  belongs_to :category

  # バリデーション
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :billing_cycle_type, presence: true
  validates :next_billing_date, presence: true
  validates :status, presence: true
  validates :memo, length: { maximum: 500 }
  validates :custom_interval, numericality: { greater_than: 0, less_than_or_equal_to: 12 }, allow_blank: true

  # カスタムバリデーション
  validate :next_billing_date_not_in_past_for_active_subscriptions

  # 新しい詳細な繰り返し間隔タイプ
  enum :billing_cycle_type, {
    daily: "daily",             # 毎日
    weekdays: "weekdays",       # 平日のみ
    weekly: "weekly",           # 毎週
    biweekly: "biweekly",       # 2週間ごと
    triweekly: "triweekly",     # 3週間ごと
    monthly: "monthly",         # 毎月
    bimonthly: "bimonthly",     # 2ヶ月ごと
    trimonthly: "trimonthly",   # 3ヶ月ごと
    quarterly: "quarterly",     # 3ヶ月（四半期）
    quadrimonthly: "quadrimonthly", # 4ヶ月ごと
    quintmonthly: "quintmonthly",   # 5ヶ月ごと
    semi_annual: "semi_annual", # 半年
    yearly: "yearly"            # 毎年
  }

  # 祝日調整オプション
  enum :holiday_adjustment, {
    none: "none",         # 調整なし
    before: "before",     # 直前の平日
    after: "after"        # 直後の平日
  }, prefix: true

  # 古いbilling_cycleとの互換性のため
  enum :billing_cycle, {
    monthly: "monthly",         # 月額
    quarterly: "quarterly",     # 3ヶ月
    semi_annual: "semi_annual", # 半年
    yearly: "yearly",           # 年額
    weekly: "weekly",           # 週額（稀だが一応）
    daily: "daily"              # 日額（稀だが一応）
  }, prefix: :legacy

  # Enum for status - Rails 7以降の書き方
  enum :status, {
    active: "active",       # アクティブ
    paused: "paused",       # 一時停止
    cancelled: "cancelled"  # 解約済み
  }

  # スコープ
  scope :active_subscriptions, -> { where(status: "active") }
  scope :billing_soon, -> { active_subscriptions.where(next_billing_date: Date.current..7.days.from_now) }
  scope :billing_today, -> { active_subscriptions.where(next_billing_date: Date.current) }
  scope :by_category_type, ->(type) { joins(:category).where(categories: { category_type: type }) }
  scope :ordered_by_next_billing, -> { order(:next_billing_date, :created_at) }
  scope :recent, -> { order(created_at: :desc) }

  # メソッド
  def formatted_amount
    "¥#{(amount || 0).to_i.to_s(:delimited)}"
  end

  def billing_cycle_type_display
    interval_text = custom_interval.present? && custom_interval > 1 ? "#{custom_interval}" : ""
    
    base_text = case billing_cycle_type
    when "daily" then "毎日"
    when "weekdays" then "平日のみ"
    when "weekly" then interval_text.present? ? "#{interval_text}週間ごと" : "毎週"
    when "biweekly" then "2週間ごと"
    when "triweekly" then "3週間ごと"
    when "monthly" then interval_text.present? ? "#{interval_text}ヶ月ごと" : "毎月"
    when "bimonthly" then "2ヶ月ごと"
    when "trimonthly" then "3ヶ月ごと"
    when "quarterly" then "四半期ごと"
    when "quadrimonthly" then "4ヶ月ごと"
    when "quintmonthly" then "5ヶ月ごと"
    when "semi_annual" then "半年ごと"
    when "yearly" then "毎年"
    else billing_cycle_type.humanize
    end
    
    # 祝日調整の表示
    adjustment_text = case holiday_adjustment
    when "before" then "（土日祝日の場合は直前の平日）"
    when "after" then "（土日祝日の場合は直後の平日）"
    else ""
    end
    
    "#{base_text}#{adjustment_text}"
  end
  
  # 古いメソッドとの互換性
  def billing_cycle_display
    return billing_cycle_type_display if billing_cycle_type.present?
    
    case billing_cycle
    when "monthly" then "月額"
    when "quarterly" then "3ヶ月"
    when "semi_annual" then "半年"
    when "yearly" then "年額"
    when "weekly" then "週額"
    when "daily" then "日額"
    else billing_cycle.humanize
    end
  end

  def formatted_amount_with_cycle
    display_text = billing_cycle_type.present? ? billing_cycle_type_display : billing_cycle_display
    "#{formatted_amount}/#{display_text}"
  end

  # 月額換算（新しいbilling_cycle_typeに対応）
  def monthly_equivalent
    return 0.0 unless amount.present?
    
    # 新しいbilling_cycle_typeがある場合はそちらを使用
    if billing_cycle_type.present?
      return calculate_monthly_equivalent_from_cycle_type
    end
    
    # 古いbilling_cycleとの互換性
    return 0.0 unless billing_cycle.present?
    
    case billing_cycle
    when "monthly" then amount.to_f
    when "quarterly" then (amount.to_f / 3)
    when "semi_annual" then (amount.to_f / 6)
    when "yearly" then (amount.to_f / 12)
    when "weekly" then (amount.to_f * 4.33) # 平均的な週数
    when "daily" then (amount.to_f * 30.44) # 平均的な日数
    else amount.to_f
    end
  end
  
  private
  
  def calculate_monthly_equivalent_from_cycle_type
    interval = custom_interval.present? ? custom_interval : 1
    
    case billing_cycle_type
    when "daily"
      if weekdays_only?
        (amount.to_f * 22) # 平均的な平日数
      else
        (amount.to_f * 30.44) # 平均的な日数
      end
    when "weekdays"
      (amount.to_f * 22) # 平均的な平日数
    when "weekly"
      (amount.to_f * 4.33) / interval # 平均的な週数
    when "biweekly"
      (amount.to_f * 4.33) / 2
    when "triweekly"
      (amount.to_f * 4.33) / 3
    when "monthly"
      amount.to_f / interval
    when "bimonthly"
      amount.to_f / 2
    when "trimonthly", "quarterly"
      amount.to_f / 3
    when "quadrimonthly"
      amount.to_f / 4
    when "quintmonthly"
      amount.to_f / 5
    when "semi_annual"
      amount.to_f / 6
    when "yearly"
      amount.to_f / 12
    else
      amount.to_f
    end
  end
  
  public

  def formatted_monthly_equivalent
    "¥#{monthly_equivalent.round.to_i.to_s.gsub(/(\d)(?=(\d{3})+(?!\d))/, '\1,')}/月"
  end

  # 次回課金までの日数
  def days_until_next_billing
    return nil unless active? && next_billing_date.present?
    (next_billing_date - Date.current).to_i
  end

  def billing_soon?
    active? && days_until_next_billing && days_until_next_billing <= 7
  end

  def billing_today?
    active? && next_billing_date.present? && next_billing_date == Date.current
  end

  # ステータス表示用
  def status_badge_class
    case status
    when "active"
      billing_today? ? "status-urgent" : billing_soon? ? "status-warning" : "status-active"
    when "paused"
      "status-paused"
    when "cancelled"
      "status-cancelled"
    else
      "status-default"
    end
  end

  def status_display_text
    case status
    when "active"
      if billing_today?
        "今日課金"
      elsif billing_soon?
        "#{days_until_next_billing}日後課金"
      else
        "アクティブ"
      end
    when "paused"
      "一時停止"
    when "cancelled"
      "解約済み"
    else
      status.humanize
    end
  end

  # 次回課金日の計算（新しいbilling_cycle_typeに対応）
  def calculate_next_billing_date(from_date = next_billing_date)
    return from_date unless from_date.present?
    
    # 新しいbilling_cycle_typeがある場合
    if billing_cycle_type.present?
      return calculate_next_billing_date_from_cycle_type(from_date)
    end
    
    # 古いbilling_cycleとの互換性
    return from_date unless billing_cycle.present?
    
    case billing_cycle
    when "daily" then from_date + 1.day
    when "weekly" then from_date + 1.week
    when "monthly" then from_date + 1.month
    when "quarterly" then from_date + 3.months
    when "semi_annual" then from_date + 6.months
    when "yearly" then from_date + 1.year
    else from_date + 1.month
    end
  end
  
  # 新しいbilling_cycle_typeに基づいた次回課金日計算
  def calculate_next_billing_date_from_cycle_type(from_date)
    interval = custom_interval.present? ? custom_interval : 1
    
    next_date = case billing_cycle_type
    when "daily"
      if weekdays_only?
        calculate_next_weekday(from_date)
      else
        from_date + 1.day
      end
    when "weekdays"
      calculate_next_weekday(from_date)
    when "weekly"
      from_date + (interval * 1.week)
    when "biweekly"
      from_date + 2.weeks
    when "triweekly"
      from_date + 3.weeks
    when "monthly"
      from_date + (interval * 1.month)
    when "bimonthly"
      from_date + 2.months
    when "trimonthly", "quarterly"
      from_date + 3.months
    when "quadrimonthly"
      from_date + 4.months
    when "quintmonthly"
      from_date + 5.months
    when "semi_annual"
      from_date + 6.months
    when "yearly"
      from_date + 1.year
    else
      from_date + 1.month
    end
    
    # 祝日調整を適用
    apply_holiday_adjustment(next_date)
  end
  
  # 次の平日を計算
  def calculate_next_weekday(from_date)
    next_date = from_date + 1.day
    while next_date.saturday? || next_date.sunday?
      next_date += 1.day
    end
    next_date
  end
  
  # 祝日調整を適用
  def apply_holiday_adjustment(date)
    return date if holiday_adjustment_none?
    
    # 土日または日曜日の場合のみ調整
    if date.saturday? || date.sunday?
      case holiday_adjustment
      when "before"
        adjust_to_previous_weekday(date)
      when "after"
        adjust_to_next_weekday(date)
      else
        date
      end
    else
      date
    end
  end
  
  # 直前の平日に調整
  def adjust_to_previous_weekday(date)
    adjusted_date = date
    while adjusted_date.saturday? || adjusted_date.sunday?
      adjusted_date -= 1.day
    end
    adjusted_date
  end
  
  # 直後の平日に調整
  def adjust_to_next_weekday(date)
    adjusted_date = date
    while adjusted_date.saturday? || adjusted_date.sunday?
      adjusted_date += 1.day
    end
    adjusted_date
  end

  # 課金処理
  def process_billing!
    return false unless active? && billing_today?

    # 取引記録を作成
    user.transactions.create!(
      category: category,
      amount: amount,
      transaction_type: "expense",
      transaction_date: Date.current,
      memo: "#{memo.presence || category.name} (サブスク自動課金)",
      vendor: "サブスク: #{memo.presence || category.name}"
    )

    # 次回課金日を更新
    update!(next_billing_date: calculate_next_billing_date)

    true
  end

  # サブスクの操作
  def pause!
    update!(status: "paused")
  end

  def resume!
    return false unless paused?

    # 次回課金日を今日から再計算
    new_next_billing = calculate_next_billing_date(Date.current)
    update!(status: "active", next_billing_date: new_next_billing)
  end

  def cancel!
    update!(status: "cancelled")
  end

  # 年間コスト計算（新しいbilling_cycle_typeに対応）
  def annual_cost
    return 0.0 unless amount.present?
    
    # 新しいbilling_cycle_typeがある場合
    if billing_cycle_type.present?
      return calculate_annual_cost_from_cycle_type
    end
    
    # 古いbilling_cycleとの互換性
    return 0.0 unless billing_cycle.present?
    
    case billing_cycle
    when "daily" then amount.to_f * 365
    when "weekly" then amount.to_f * 52
    when "monthly" then amount.to_f * 12
    when "quarterly" then amount.to_f * 4
    when "semi_annual" then amount.to_f * 2
    when "yearly" then amount.to_f
    else amount.to_f * 12
    end
  end
  
  def calculate_annual_cost_from_cycle_type
    interval = custom_interval.present? ? custom_interval : 1
    
    case billing_cycle_type
    when "daily"
      if weekdays_only?
        amount.to_f * 260 # 平年の平日数（約260日）
      else
        amount.to_f * 365
      end
    when "weekdays"
      amount.to_f * 260
    when "weekly"
      (amount.to_f * 52) / interval
    when "biweekly"
      amount.to_f * 26
    when "triweekly"
      amount.to_f * (52.0 / 3).round(2)
    when "monthly"
      (amount.to_f * 12) / interval
    when "bimonthly"
      amount.to_f * 6
    when "trimonthly", "quarterly"
      amount.to_f * 4
    when "quadrimonthly"
      amount.to_f * 3
    when "quintmonthly"
      amount.to_f * (12.0 / 5).round(2)
    when "semi_annual"
      amount.to_f * 2
    when "yearly"
      amount.to_f
    else
      amount.to_f * 12
    end
  end

  def formatted_annual_cost
    "¥#{annual_cost.round.to_s(:delimited)}/年"
  end

  # バッチ処理用 - 今日課金が必要なサブスクを処理
  def self.process_daily_billing!
    billing_today.find_each(&:process_billing!)
  end

  private

  def next_billing_date_not_in_past_for_active_subscriptions
    return unless next_billing_date.present? && status.present?
    return if cancelled? || paused?

    if next_billing_date < Date.current
      errors.add(:next_billing_date, "は今日以降の日付を設定してください")
    end
  end
end
