class CarsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]

  def index
    cars = Car.includes(:car_images, :user)
    render json: cars.map { |car| car_response(car) }
  end

  def show
    car = Car.includes(:car_images, :user).find(params[:id])
    render json: car_response(car)
  end

  def create
    car = current_user.cars.build(car_params)

    if params[:images].present?
      params[:images].each_with_index do |image, i|
        car.car_images.build(image: image, position: i)
      end
    end

    if car.save
      render json: car_response(car), status: :created
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
      render json: car_response(car)
    else
      render json: { errors: car.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def my_cars
    cars = current_user.cars.includes(:car_images, :user)
    render json: cars.map { |car| car_response(car) }
  end

  private

  def car_params
    params.permit(
      :title,
      :description,
      :location,
      :price,
      :fuel_type,
      :transmission,
      :engine_capacity,
      :horsepower,
      :year,
      :drive,
      :has_air_conditioner,
      :category
    )
  end

  def car_response(car)
    user = car.user

    {
      id: car.id,
      user_id: car.user_id,
      title: car.title,
      description: car.description,
      location: car.location,
      price: car.price,
      fuel_type: car.fuel_type,
      transmission: car.transmission,
      engine_capacity: car.engine_capacity,
      horsepower: car.horsepower,
      year: car.year,
      drive: car.drive,
      has_air_conditioner: car.has_air_conditioner,
      category: car.category,
      created_at: car.created_at,
      updated_at: car.updated_at,
      car_images: car.car_images.order(:position).map do |img|
        { id: img.id, url: img.image_url, position: img.position }
      end,
      custom_fields: [
        { key: "Кондиционер", value: car.has_air_conditioner ? "есть" : "нет" }
      ],
      contacts: {
        phone_1: user.phone_1,
        phone_2: user.phone_2,
        whatsapp: user.whatsapp,
        telegram: user.telegram,
        instagram: user.instagram,
        website: user.website
      }
    }
  end
end
