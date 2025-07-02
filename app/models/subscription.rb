class Subscription < ApplicationRecord
  # 関連付け
  belongs_to :user
  belongs_to :category

  # バリデーション
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :billing_cycle, presence: true
  validates :next_billing_date, presence: true
  validates :status, presence: true
  validates :memo, length: { maximum: 500 }

  # カスタムバリデーション
  validate :next_billing_date_not_in_past_for_active_subscriptions

  # Enum for billing cycles - Rails 7以降の書き方
  enum :billing_cycle, {
    monthly: "monthly",         # 月額
    quarterly: "quarterly",     # 3ヶ月
    semi_annual: "semi_annual", # 半年
    yearly: "yearly",           # 年額
    weekly: "weekly",           # 週額（稀だが一応）
    daily: "daily"              # 日額（稀だが一応）
  }

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

  def billing_cycle_display
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
    "#{formatted_amount}/#{billing_cycle_display}"
  end

  # 月額換算
  def monthly_equivalent
    return 0.0 unless amount.present? && billing_cycle.present?

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

  # 次回課金日の計算
  def calculate_next_billing_date(from_date = next_billing_date)
    return from_date unless from_date.present? && billing_cycle.present?

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

  # 年間コスト計算
  def annual_cost
    return 0.0 unless amount.present? && billing_cycle.present?

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
