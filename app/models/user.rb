class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # 関連付け
  has_many :transactions, dependent: :destroy
  has_many :reservations, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :budgets, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :custom_categories, -> { where.not(user_id: nil) }, class_name: 'Category', dependent: :destroy
  
  # 統計用メソッド
  
  # 今月の支出合計
  def current_month_expenses
    transactions.expense.current_month.sum(:amount) || 0.0
  end
  
  # 今月の収入合計
  def current_month_income
    transactions.income.current_month.sum(:amount) || 0.0
  end
  
  # 今月の差額（収入 - 支出）
  def current_month_balance
    current_month_income - current_month_expenses
  end
  
  # 推し活支出（今月）
  def current_month_oshi_expenses
    transactions.oshi_expenses.current_month.sum(:amount) || 0.0
  end
  
  # 月額サブスク合計
  def monthly_subscription_total
    active_subs = subscriptions.active_subscriptions
    return 0.0 if active_subs.empty?
    
    active_subs.sum { |sub| sub.monthly_equivalent || 0.0 }
  end
  
  # 支払い予定額（今月）
  def current_month_pending_payments
    now = Time.current
    active_reservations = reservations.active.by_month(now.year, now.month)
    return 0.0 if active_reservations.empty?
    
    active_reservations.sum { |reservation| reservation.remaining_amount || 0.0 }
  end
  
  # 支払い期限が近い予約
  def urgent_reservations
    reservations.due_soon.ordered_by_due_date
  end
  
  # 今日課金されるサブスク
  def billing_today_subscriptions
    subscriptions.billing_today.ordered_by_next_billing
  end
  
  # カテゴリ別支出分析（今月）
  def current_month_expenses_by_category
    result = transactions.expense.current_month
                        .joins(:category)
                        .group('categories.name')
                        .sum(:amount)
    
    # Symbolキーを文字列キーに変換し、値を確実に数値にする
    result.transform_keys(&:to_s).transform_values { |v| (v || 0.0).to_f }
  end
  
  # 推し活支出の割合（今月）
  def oshi_expense_percentage
    total = current_month_expenses
    return 0.0 if total <= 0
    
    oshi_total = current_month_oshi_expenses
    ((oshi_total / total) * 100).round(1)
  end
  
  # 月別支出推移（過去12ヶ月）
  def monthly_expense_trend
    12.times.map do |i|
      date = i.months.ago
      amount = transactions.expense.by_month(date.year, date.month).sum(:amount) || 0.0
      {
        month: date.strftime('%Y/%m'),
        amount: amount.to_f
      }
    end.reverse
  end
  
  # ダッシュボード用サマリー
  def dashboard_summary
    {
      current_month_expenses: current_month_expenses.to_f,
      current_month_income: current_month_income.to_f,
      current_month_balance: current_month_balance.to_f,
      oshi_expenses: current_month_oshi_expenses.to_f,
      monthly_subscriptions: monthly_subscription_total.to_f,
      pending_payments: current_month_pending_payments.to_f,
      oshi_percentage: oshi_expense_percentage.to_f
    }
  end
  
  # 表示用フォーマット
  def display_name
    email.split('@').first.capitalize
  end
  
  # アクティブな予約数
  def active_reservations_count
    reservations.active.count
  end
  
  # アクティブなサブスク数
  def active_subscriptions_count
    subscriptions.active_subscriptions.count
  end
  
  # 今月の取引数
  def current_month_transactions_count
    transactions.current_month.count
  end
end