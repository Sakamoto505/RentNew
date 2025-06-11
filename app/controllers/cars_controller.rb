
  class CarsController < ApplicationController
    before_action :authenticate_user!

    def index
      cars = Car.all
      render json: cars
    end

    def show
      car = Car.includes(:car_images, :user).find(params[:id])
      owner = car.user

      render json: {
        id: car.id,
        title: car.title,
        description: car.description,
        category: car.category,
        location: car.location,
        price_per_day: car.price,
        year: car.year,
        engine_capacity: car.engine_capacity,
        contacts: {
          whatsapp: {
            number: owner.whatsapp,
            label: "WhatsApp — для бронирования"
          },
          telegram: {
            handle: owner.telegram,
            label: "Telegram — быстрые ответы"
          },
          phone_1: {
            number: owner.phone,
            label: "Основной номер"
          },
        },
        images: car.car_images.map(&:image_url),
        custom_fields: [
          { key: "Тип кузова", value: car.body_type },
          { key: "Коробка передач", value: car.gearbox_type },
          { key: "Кондиционер", value: car.has_air_conditioner ? "есть" : "нет" },
          { key: "Салон", value: car.interior_description },
          { key: "Цвет", value: car.color },
          { key: "Пробег", value: car.mileage }
        ],
        specs: {
          fuel: car.fuel_type,
          drive: car.transmission
        },
        created_at: car.created_at
      }
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
