class Transaction < ApplicationRecord
  # 関連付け
  belongs_to :user
  belongs_to :category

  # コールバック
  after_commit :update_budget_spent, on: [ :create, :update, :destroy ]

  # バリデーション
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :transaction_type, presence: true
  validates :transaction_date, presence: true
  validates :memo, length: { maximum: 500 }
  validates :vendor, length: { maximum: 100 }
  validates :satisfaction_rating,
            numericality: {
              greater_than_or_equal_to: 1,
              less_than_or_equal_to: 5,
              allow_nil: true
            }

  # Enum for transaction types - Rails 7以降の書き方
  enum :transaction_type, {
    expense: "expense",   # 支出
    income: "income"      # 収入
  }

  # スコープ
  scope :by_date, ->(date) { where(transaction_date: date) }
  scope :by_month, ->(year, month) {
    where(transaction_date: Date.new(year, month, 1)..Date.new(year, month, -1))
  }
  scope :by_year, ->(year) { where(transaction_date: Date.new(year, 1, 1)..Date.new(year, 12, 31)) }
  scope :recent, -> { order(transaction_date: :desc, created_at: :desc) }
  scope :by_category_type, ->(type) { joins(:category).where(categories: { category_type: type }) }

  # 集計用スコープ
  scope :total_amount, -> { sum(:amount) }
  scope :expenses_total, -> { expense.sum(:amount) }
  scope :income_total, -> { income.sum(:amount) }

  # 今月の取引
  scope :current_month, -> {
    now = Time.current
    by_month(now.year, now.month)
  }

  # 推し活支出
  scope :oshi_expenses, -> { expense.by_category_type("oshi") }

  # メソッド
  def expense?
    transaction_type == "expense"
  end

  def income?
    transaction_type == "income"
  end

  def formatted_amount
    "¥#{(amount || 0).to_i.to_s(:delimited)}"
  end

  def signed_amount
    expense? ? -(amount || 0) : (amount || 0)
  end

  def formatted_signed_amount
    prefix = expense? ? "-" : "+"
    amount_value = (amount || 0).to_i
    formatted_amount = amount_value.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\1,').reverse
    "#{prefix}¥#{formatted_amount}"
  end

  # 満足度の星表示
  def satisfaction_stars
    return "未評価" unless satisfaction_rating.present?
    "★" * satisfaction_rating + "☆" * (5 - satisfaction_rating)
  end

  # 日付のフォーマット
  def formatted_date
    return "" unless transaction_date.present?
    transaction_date.strftime("%Y/%m/%d")
  end

  def formatted_date_short
    return "" unless transaction_date.present?
    transaction_date.strftime("%m/%d")
  end

  private

  def update_budget_spent
    return unless expense? && transaction_date.present?

    month = transaction_date.beginning_of_month

    # 全体予算を更新
    total_budget = user.budgets.total_budget.for_month(month).first
    if total_budget
      spent = user.transactions.expense.by_month(month.year, month.month).sum(:amount)
      total_budget.update(spent: spent)
    end

    # カテゴリ予算を更新
    if category_id.present?
      category_budget = user.budgets.for_month(month).where(category_id: category_id).first
      if category_budget
        spent = user.transactions.expense.by_month(month.year, month.month)
                   .where(category_id: category_id).sum(:amount)
        category_budget.update(spent: spent)
      end
    end
  end
end
