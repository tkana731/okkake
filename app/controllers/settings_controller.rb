class SettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_budget, only: [:index]

  def index
    @budgets = current_user.budgets.for_month(Date.current).includes(:category)
    @total_budget = @budgets.total_budget.first_or_initialize
    @category_budgets = @budgets.category_budgets
    @categories = Category.available_for_user(current_user).order(:name)
  end

  def update_budget
    @budget = current_user.budgets.find_or_initialize_by(budget_params.slice(:month, :category_id))
    @budget.amount = budget_params[:amount]

    if @budget.save
      redirect_to settings_path, notice: '予算を更新しました。'
    else
      redirect_to settings_path, alert: '予算の更新に失敗しました。'
    end
  end

  def delete_budget
    @budget = current_user.budgets.find(params[:id])
    @budget.destroy
    redirect_to settings_path, notice: '予算を削除しました。'
  end

  private

  def set_budget
    current_month = Date.current.beginning_of_month
    # 今月の全体予算を取得または初期化
    @total_budget = current_user.budgets.total_budget.for_month(current_month).first_or_initialize do |budget|
      budget.month = current_month
      budget.spent = calculate_current_month_spent
    end
  end

  def budget_params
    params.require(:budget).permit(:amount, :month, :category_id)
  end

  def calculate_current_month_spent(category_id = nil)
    transactions = current_user.transactions.expense.current_month
    transactions = transactions.where(category_id: category_id) if category_id
    transactions.sum(:amount)
  end
end
