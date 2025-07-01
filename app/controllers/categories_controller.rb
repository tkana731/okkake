class CategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_category, only: [:show, :edit, :update, :destroy]
  before_action :ensure_custom_category, only: [:edit, :update, :destroy]

  def index
    @default_categories = Category.default_categories.root_categories.includes(:children)
    @custom_categories = current_user.custom_categories.root_categories.includes(:children)
  end

  def show
  end

  def new
    @category = current_user.categories.build
    @parent_categories = Category.available_for_user(current_user).root_categories
  end

  def create
    Rails.logger.debug "=== カテゴリ作成デバッグ情報 ==="
    Rails.logger.debug "current_user: #{current_user.inspect}"
    Rails.logger.debug "category_params: #{category_params.inspect}"
    Rails.logger.debug "Category.column_names: #{Category.column_names.inspect}"
    
    @category = current_user.categories.build(category_params)
    Rails.logger.debug "作成されたカテゴリ: #{@category.inspect}"
    Rails.logger.debug "カテゴリ属性: #{@category.attributes.inspect}"
    
    if @category.save
      redirect_to categories_path, notice: 'カテゴリが作成されました。'
    else
      Rails.logger.debug "バリデーションエラー: #{@category.errors.full_messages.inspect}"
      @parent_categories = Category.available_for_user(current_user).root_categories
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @parent_categories = Category.available_for_user(current_user).root_categories
  end

  def update
    if @category.update(category_params)
      redirect_to categories_path, notice: 'カテゴリが更新されました。'
    else
      @parent_categories = Category.available_for_user(current_user).root_categories
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @category.transactions.any? || @category.reservations.any? || @category.subscriptions.any?
      redirect_to categories_path, alert: 'このカテゴリは使用中のため削除できません。'
    else
      @category.destroy
      redirect_to categories_path, notice: 'カテゴリが削除されました。'
    end
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def ensure_custom_category
    unless @category.custom_category? && @category.user == current_user
      redirect_to categories_path, alert: 'このカテゴリは編集できません。'
    end
  end

  def category_params
    params.require(:category).permit(:name, :icon, :color, :category_type, :parent_id)
  end
end
