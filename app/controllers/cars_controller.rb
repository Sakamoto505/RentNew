
  class CarsController < ApplicationController
    before_action :authenticate_user!

    def index
      cars = Car.all
      render json: cars
    end

    def show
      car = Car.find(params[:id])
      render json: car
    end

    def create
      car = current_user.cars.build(car_params)
      if car.save
        render json: car, status: :created
      else
        render json: { errors: car.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def car_params
      params.require(:car).permit(
        :title, :description, :price, :transmission, :engine_capacity,
        :year, :location, :category, :drive_type, :fuel_type
      )
    end
end
