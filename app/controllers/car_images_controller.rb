class CarImagesController < ApplicationController
  before_action :authenticate_user!

  def destroy
    car_image = current_user.cars.joins(:car_images).find_by(car_images: { id: params[:id] })&.car_images&.find_by(id: params[:id])

    if car_image
      car_image.destroy
      render json: { status: 'ok', message: 'Фото удалено' }
    else
      render json: { error: 'Фото не найдено' }, status: :not_found
    end
  end
end