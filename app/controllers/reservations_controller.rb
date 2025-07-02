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
    params.require(:reservation).permit(:memo, :total_amount, :paid_amount, :due_date, :status, :reservation_type, :category_id)
  end
end
