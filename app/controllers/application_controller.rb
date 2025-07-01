class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  # Deviseのリダイレクト先を設定
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  
  # ログイン後のリダイレクト先
  def after_sign_in_path_for(resource)
    root_path
  end
  
  # ログアウト後のリダイレクト先
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end
  
  protected
  
  # Deviseで許可するパラメータを追加
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end
  
  private
  
  # エラーハンドリング
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActionController::ParameterMissing, with: :parameter_missing
  
  def record_not_found
    redirect_to root_path, alert: 'お探しのページが見つかりませんでした。'
  end
  
  def parameter_missing
    redirect_to root_path, alert: '必要なパラメータが不足しています。'
  end
  
  # ページネーション用のデフォルト設定
  def per_page
    params[:per_page]&.to_i || 20
  end
  
  # 日付範囲の取得（フィルタリング用）
  def date_range
    start_date = params[:start_date]&.to_date || Date.current.beginning_of_month
    end_date = params[:end_date]&.to_date || Date.current.end_of_month
    start_date..end_date
  end
  
  # JSON形式のレスポンス用ヘルパー
  def render_json_success(data = {}, message = nil)
    render json: {
      success: true,
      message: message,
      data: data
    }
  end
  
  def render_json_error(message, errors = [])
    render json: {
      success: false,
      message: message,
      errors: errors
    }, status: :unprocessable_entity
  end
end