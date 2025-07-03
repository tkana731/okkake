class ReservationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reservation, only: [ :show, :edit, :update, :destroy ]

  def index
    @reservations = current_user.reservations.includes(:user).recent
  end

  def show
  end

  def new
    @reservation_type = params[:type] || "confirmed"
    @reservation = current_user.reservations.build(reservation_type: @reservation_type)
    @categories = Category.available_for_user(current_user).distinct.order(:name)
  end

  def create
    @reservation = current_user.reservations.build(reservation_params)

    if @reservation.save
      redirect_to reservations_path, notice: "予約が作成されました。"
    else
      @reservation_type = @reservation.reservation_type
      @categories = Category.available_for_user(current_user).distinct.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @categories = Category.available_for_user(current_user).distinct.order(:name)
    # 抽選購入で lottery_announcement_time が設定されていない場合、due_date から作成
    if @reservation.lottery? && @reservation.lottery_announcement_time.blank? && @reservation.due_date.present?
      @reservation.lottery_announcement_time = Time.zone.parse("#{@reservation.due_date} 00:00:00")
    end
  end

  def update
    if @reservation.update(reservation_params)
      redirect_to reservation_path(@reservation), notice: "予約が更新されました。"
    else
      @categories = Category.available_for_user(current_user).distinct.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @reservation.destroy!
    redirect_to reservations_path, notice: "予約が削除されました。"
  end

  private

  def set_reservation
    @reservation = current_user.reservations.find(params[:id])
  end

  def reservation_params
    permitted = params.require(:reservation).permit(:memo, :total_amount, :paid_amount, :due_date, :status, :reservation_type, :category_id, :lottery_announcement_time, :lottery_has_time)

    Rails.logger.debug "=== Original params ==="
    Rails.logger.debug "lottery_has_time: #{permitted[:lottery_has_time]}"
    Rails.logger.debug "lottery_announcement_time: #{permitted[:lottery_announcement_time]}"
    Rails.logger.debug "due_date: #{permitted[:due_date]}"

    # 抽選購入の場合の日時処理
    if permitted[:reservation_type] == "lottery"
      if permitted[:lottery_has_time] == "1" && permitted[:lottery_announcement_time].present?
        # 時間指定がある場合：lottery_announcement_timeをJSTで解釈
        begin
          # datetime-local は "YYYY-MM-DDTHH:MM" の形式で送信される
          # これをJSTとして解釈してUTCに変換せずに保存
          datetime_str = permitted[:lottery_announcement_time]
          Rails.logger.debug "Original datetime string: #{datetime_str}"

          # JSTタイムゾーンで解釈
          datetime = Time.zone.parse(datetime_str)
          permitted[:lottery_announcement_time] = datetime
          permitted[:due_date] = datetime.to_date

          Rails.logger.debug "=== Time specified ==="
          Rails.logger.debug "Parsed datetime (JST): #{datetime}"
          Rails.logger.debug "UTC: #{datetime.utc}"
        rescue ArgumentError => e
          # パース失敗時はlottery_announcement_timeをクリア
          permitted[:lottery_announcement_time] = nil
          Rails.logger.debug "=== Parse error ==="
          Rails.logger.debug "Error: #{e.message}"
        end
      elsif permitted[:due_date].present?
        # 時間指定がない場合：due_dateから00:00のlottery_announcement_timeを作成
        begin
          date = Date.parse(permitted[:due_date])
          # JSTの00:00で作成
          permitted[:lottery_announcement_time] = Time.zone.parse("#{date} 00:00:00")
          permitted[:due_date] = date
          Rails.logger.debug "=== Date only ==="
          Rails.logger.debug "Date: #{date}"
          Rails.logger.debug "JST 00:00: #{permitted[:lottery_announcement_time]}"
        rescue ArgumentError
          permitted[:lottery_announcement_time] = nil
        end
      else
        # 両方とも空の場合
        permitted[:lottery_announcement_time] = nil
        Rails.logger.debug "=== Both empty ==="
      end
    end

    Rails.logger.debug "=== Final params ==="
    Rails.logger.debug "lottery_announcement_time: #{permitted[:lottery_announcement_time]}"
    Rails.logger.debug "due_date: #{permitted[:due_date]}"

    # 不要なパラメータを削除
    permitted.except(:lottery_has_time)
  end
end
