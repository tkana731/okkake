class TransactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_transaction, only: [ :show, :edit, :update, :destroy ]

  def index
    @transactions = current_user.transactions
                                .includes(:category)
                                .recent

    # フィルタリング
    if params[:category_id].present?
      @transactions = @transactions.where(category_id: params[:category_id])
    end

    if params[:transaction_type].present?
      @transactions = @transactions.where(transaction_type: params[:transaction_type])
    end

    if params[:start_date].present? && params[:end_date].present?
      @transactions = @transactions.where(transaction_date: params[:start_date]..params[:end_date])
    end

    # ページネーション（kaminariがあれば）
    # @transactions = @transactions.page(params[:page]).per(per_page)
    @transactions = @transactions.limit(50) # 暫定的に50件まで

    # 統計情報
    @total_expenses = current_user.transactions.expense.sum(:amount)
    @total_income = current_user.transactions.income.sum(:amount)
    @current_month_expenses = current_user.current_month_expenses
    @current_month_income = current_user.current_month_income

    # フィルタ用のデータ
    @categories = Category.available_for_user(current_user).where.not(parent_id: nil).order(:name)
  end

  def show
    # 個別の取引詳細（必要に応じて）
  end

  def new
    @transaction = current_user.transactions.build
    @transaction.transaction_date = Date.current # デフォルト日付を設定
  end

  def create
    @transaction = current_user.transactions.build(transaction_params)

    if @transaction.save
      redirect_to transactions_path,
                  notice: "#{@transaction.transaction_type == 'expense' ? '支出' : '収入'}を記録しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @transaction.update(transaction_params)
      redirect_to transactions_path, notice: "取引を更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    transaction_type = @transaction.transaction_type == "expense" ? "支出" : "収入"
    @transaction.destroy
    redirect_to transactions_path, notice: "#{transaction_type}記録を削除しました。"
  end

  # 統計情報をAjaxで取得
  def stats
    stats_data = {
      current_month: {
        expenses: current_user.current_month_expenses,
        income: current_user.current_month_income,
        balance: current_user.current_month_balance,
        oshi_expenses: current_user.current_month_oshi_expenses,
        oshi_percentage: current_user.oshi_expense_percentage
      },
      category_breakdown: current_user.current_month_expenses_by_category,
      monthly_trend: current_user.monthly_expense_trend
    }

    render json: stats_data
  end

  private

  def set_transaction
    @transaction = current_user.transactions.find(params[:id])
  end

  def transaction_params
    params.require(:transaction).permit(
      :amount,
      :transaction_type,
      :transaction_date,
      :category_id,
      :memo,
      :vendor,
      :satisfaction_rating
    )
  end
end
