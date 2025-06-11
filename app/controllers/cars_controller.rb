
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

      if params[:images].present?
        params[:images].each_with_index do |image, i|
          car.car_images.build(image: image, position: i)
        end
      end

      if car.save
        render json: car.as_json(include: {
          car_images: { only: [:id, :position], methods: [:image_url] }
        }), status: :created
      else
        render json: { errors: car.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      car = current_user.cars.find(params[:id])

      if params[:images].present?
        params[:images].each_with_index do |image, i|
          car.car_images.build(image: image, position: car.car_images.size + i)
        end
      end

      if car.update(car_params)
        render json: car.as_json(include: {
          car_images: { only: [:id, :position], methods: [:image_url] }
        })
      else
        render json: { errors: car.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def my_cars
        cars = current_user.cars.includes(:car_images)

        render json: cars.as_json(include: {
          car_images: { only: [:id, :position], methods: [:image_url] }
        })
      end
    private

    def car_params
      params.permit(:title, :description, :price, :transmission, :engine_capacity,
                    :year, :location, :category, :fuel_type)
    end

  end
