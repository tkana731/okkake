class DashboardController < ApplicationController
  before_action :authenticate_user!
  
  def index
    # エラーハンドリングを追加した安全なデータ取得
    begin
      # ダッシュボード用のデータを取得
      @summary = current_user.dashboard_summary
      
      # 統計カード用のデータ（安全な数値処理）
      @current_month_expenses = (current_user.current_month_expenses || 0.0).to_f
      @oshi_expenses = (current_user.current_month_oshi_expenses || 0.0).to_f
      @monthly_subscriptions = (current_user.monthly_subscription_total || 0.0).to_f
      @current_month_balance = (current_user.current_month_balance || 0.0).to_f
      
      # 支払い予定（期限が近い順で最大5件）
      @urgent_reservations = current_user.urgent_reservations.limit(5)
      
      # サブスクリプション（次回課金日が近い順で最大5件）
      @upcoming_subscriptions = current_user.subscriptions
                                            .active_subscriptions
                                            .ordered_by_next_billing
                                            .limit(5)
      
      # 最近の取引（最大10件）
      @recent_transactions = current_user.transactions
                                        .recent
                                        .includes(:category)
                                        .limit(10)
      
      # カテゴリ選択用のデータ
      @categories_by_type = Category.includes(:children)
                                    .where(parent_id: nil)
                                    .group_by(&:category_type)
      
      # フォーム用の新しいオブジェクト
      @new_transaction = current_user.transactions.build
      
      # カテゴリ別支出分析（安全な処理）
      @expenses_by_category = current_user.current_month_expenses_by_category || {}
      
      # 月別支出推移
      @monthly_trend = current_user.monthly_expense_trend || []
      
      # アラート情報
      @alerts = build_alerts
      
      # 予算情報
      @total_budget = current_user.budgets.total_budget.for_month(Date.current).first
      
    rescue => e
      # エラーが発生した場合のフォールバック
      Rails.logger.error "Dashboard data loading error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      
      # デフォルト値を設定
      @current_month_expenses = 0.0
      @oshi_expenses = 0.0
      @monthly_subscriptions = 0.0
      @current_month_balance = 0.0
      @urgent_reservations = []
      @upcoming_subscriptions = []
      @recent_transactions = []
      @categories_by_type = {}
      @new_transaction = current_user.transactions.build
      @expenses_by_category = {}
      @monthly_trend = []
      @alerts = []
      @total_budget = nil
      
      # フラッシュメッセージでエラーを通知
      flash.now[:alert] = "データの読み込み中にエラーが発生しました。"
    end
  end
  
  private
  
  def build_alerts
    alerts = []
    
    begin
      # 期限切れの予約
      overdue_reservations = current_user.reservations.where('due_date < ? AND status IN (?)', 
                                                             Date.current, 
                                                             ['pending', 'partial_paid'])
      if overdue_reservations.any?
        alerts << {
          type: 'danger',
          message: "#{overdue_reservations.count}件の支払いが期限切れです。",
          icon: 'fas fa-exclamation-triangle',
          link: reservations_path
        }
      end
      
      # 明日期限の予約
      due_tomorrow = current_user.reservations.active
                                 .where(due_date: Date.current + 1.day)
      if due_tomorrow.any?
        alerts << {
          type: 'warning',
          message: "明日期限の支払いが#{due_tomorrow.count}件あります。",
          icon: 'fas fa-clock',
          link: reservations_path
        }
      end
      
      # 今日課金されるサブスク
      billing_today = current_user.subscriptions.billing_today
      if billing_today.any?
        total_amount = billing_today.sum(:amount) || 0.0
        alerts << {
          type: 'info',
          message: "今日#{billing_today.count}件のサブスクが課金されます（合計¥#{total_amount.to_i.to_s(:delimited)}）。",
          icon: 'fas fa-credit-card',
          link: subscriptions_path
        }
      end
      
      # 予算超過の警告
      total_budget = current_user.budgets.total_budget.for_month(Date.current).first
      if total_budget && total_budget.amount > 0
        expenses = @current_month_expenses || 0.0
        
        if total_budget.over_budget?
          over_amount = expenses - total_budget.amount
          alerts << {
            type: 'danger',
            message: "今月の支出が予算を¥#{over_amount.to_i.to_s(:delimited)}超過しています。",
            icon: 'fas fa-chart-line',
            link: transactions_path
          }
        elsif total_budget.percentage_used >= 80
          alerts << {
            type: 'warning',
            message: "今月の支出が予算の#{total_budget.percentage_used.to_i}%に達しました。",
            icon: 'fas fa-chart-line',
            link: transactions_path
          }
        end
      end
      
    rescue => e
      Rails.logger.error "Alert building error: #{e.message}"
      # エラーが発生してもアラートは空配列を返す
    end
    
    alerts
  end
end