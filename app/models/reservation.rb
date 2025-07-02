class Reservation < ApplicationRecord
  # 関連付け
  belongs_to :user
  belongs_to :category

  # バリデーション
  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :paid_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :due_date, presence: true
  validates :status, presence: true
  validates :reservation_type, presence: true
  validates :memo, length: { maximum: 500 }

  # カスタムバリデーション
  validate :paid_amount_not_greater_than_total
  validate :due_date_not_in_past_for_pending_reservations

  # Enum for status - Rails 7以降の書き方
  enum :status, {
    pending: "pending",           # 予約済み（未払い）
    partial_paid: "partial_paid", # 内金支払済み
    paid: "paid",                 # 全額支払済み
    cancelled: "cancelled",       # キャンセル
    overdue: "overdue"           # 期限切れ
  }

  # Enum for reservation_type
  enum :reservation_type, {
    confirmed: "confirmed",       # 予約購入（購入確定）
    lottery: "lottery"           # 抽選購入（当選確定後購入）
  }

  # スコープ
  scope :active, -> { where(status: [ "pending", "partial_paid" ]) }
  scope :due_soon, -> { active.where(due_date: Date.current..7.days.from_now) }
  scope :overdue_check, -> { pending.where(due_date: ...Date.current) }
  scope :by_month, ->(year, month) {
    where(due_date: Date.new(year, month, 1)..Date.new(year, month, -1))
  }
  scope :ordered_by_due_date, -> { order(:due_date, :created_at) }
  scope :recent, -> { order(created_at: :desc) }

  # メソッド
  def remaining_amount
    return 0.0 unless total_amount.present? && paid_amount.present?

    remaining = total_amount.to_f - paid_amount.to_f
    remaining < 0 ? 0.0 : remaining
  end

  def formatted_total_amount
    "¥#{(total_amount || 0).to_i.to_s(:delimited)}"
  end

  def formatted_paid_amount
    "¥#{(paid_amount || 0).to_i.to_s(:delimited)}"
  end

  def formatted_remaining_amount
    "¥#{remaining_amount.to_i.to_s(:delimited)}"
  end

  def payment_progress_percentage
    return 0 if total_amount.nil? || total_amount.zero?
    ((paid_amount.to_f / total_amount.to_f) * 100).round(1)
  end

  def due_in_days
    return 0 unless due_date.present?
    (due_date - Date.current).to_i
  end

  def overdue?
    status == "overdue" || (active? && due_date.present? && due_date < Date.current)
  end

  def due_soon?
    active? && due_date.present? && due_date <= 3.days.from_now
  end

  def active?
    pending? || partial_paid?
  end

  def fully_paid?
    remaining_amount.zero?
  end

  # ステータス表示用
  def status_badge_class
    case status
    when "pending"
      due_soon? ? "status-urgent" : "status-pending"
    when "partial_paid"
      "status-partial"
    when "paid"
      "status-completed"
    when "cancelled"
      "status-cancelled"
    when "overdue"
      "status-urgent"
    else
      "status-default"
    end
  end

  def status_display_text
    case status
    when "pending"
      if overdue?
        "期限切れ"
      elsif due_soon?
        "#{due_in_days}日後期限"
      else
        "予約中"
      end
    when "partial_paid"
      "内金済み (#{payment_progress_percentage}%)"
    when "paid"
      "支払完了"
    when "cancelled"
      "キャンセル"
    when "overdue"
      "期限切れ"
    else
      status.humanize
    end
  end

  def reservation_type_display_text
    case reservation_type
    when "confirmed"
      "予約購入"
    when "lottery"
      "抽選購入"
    else
      reservation_type.humanize
    end
  end

  # 支払い処理
  def mark_as_paid!
    update!(status: "paid", paid_amount: total_amount)
  end

  def add_partial_payment!(amount)
    new_paid_amount = (paid_amount || 0) + amount.to_f
    if new_paid_amount >= total_amount.to_f
      mark_as_paid!
    else
      update!(paid_amount: new_paid_amount, status: "partial_paid")
    end
  end

  # 期限切れチェック（バッチ処理用）
  def self.mark_overdue!
    overdue_check.update_all(status: "overdue")
  end

  private

  def paid_amount_not_greater_than_total
    return unless paid_amount.present? && total_amount.present?

    if paid_amount.to_f > total_amount.to_f
      errors.add(:paid_amount, "は総額を超えることはできません")
    end
  end

  def due_date_not_in_past_for_pending_reservations
    return unless due_date.present? && status.present?
    return if paid? || cancelled?

    if due_date < Date.current
      errors.add(:due_date, "は今日以降の日付を設定してください")
    end
  end
end
