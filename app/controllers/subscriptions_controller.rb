class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_subscription, only: [ :show, :edit, :update, :destroy ]

  def index
    @subscriptions = current_user.subscriptions.includes(:user).recent
  end

  def show
  end

  def new
    @subscription = current_user.subscriptions.build
    @categories = Category.all
  end

  def create
    @subscription = current_user.subscriptions.build(subscription_params)

    if @subscription.save
      redirect_to subscriptions_path, notice: "サブスクリプションが作成されました。"
    else
      @categories = Category.all
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @subscription.update(subscription_params)
      redirect_to subscription_path(@subscription), notice: "サブスクリプションが更新されました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @subscription.destroy!
    redirect_to subscriptions_path, notice: "サブスクリプションが削除されました。"
  end

  private

  def set_subscription
    @subscription = current_user.subscriptions.find(params[:id])
  end

  def subscription_params
    params.require(:subscription).permit(
      :memo, :amount, :billing_cycle, :next_billing_date, :status, :category_id,
      :billing_cycle_type, :custom_interval, :weekdays_only, :holiday_adjustment
    )
  end
end
