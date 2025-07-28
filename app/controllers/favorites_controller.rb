class FavoritesController < ApplicationController
  before_action :authenticate_user!

  def index
    favorites = current_user.favorite_cars.includes(:car_images, :user)
    render json: favorites.map { |car| car_response(car) }
  end

  def create
    car = Car.find(params[:car_id])
    current_user.favorites.find_or_create_by!(car: car)
    render json: { success: true }
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def destroy
    favorite = current_user.favorites.find_by(car_id: params[:car_id])
    if favorite
      favorite.destroy
      render json: { success: true }
    else
      render json: { error: "Избранное не найдено" }, status: :not_found
    end
  end


  private

  def car_response(car)
    CarSerializer.call(car)
  end
end
