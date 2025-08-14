class CarsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]

  def index
    cars = Car.includes(:car_images, :user).order(created_at: :desc)

    if params[:category].present?
      category_param = params[:category].to_s.downcase
      
      # Check if the category exists in our enum
      if Car.categories.key?(category_param)
        cars = cars.where(category: category_param)
      else
        # Return no results for invalid categories
        cars = Car.none
      end
    end

    # Set limit to 12 for category filtering, otherwise use default pagination
    items_per_page = params[:category].present? ? 12 : (params[:per_page] || 20)
    pagy, records = pagy(cars, items: items_per_page)

    render json: {
      cars: records.map { |car| car_response(car) },
      meta: {
        page: pagy.page,
        per_page: pagy.vars[:items],
        total: pagy.count,
        pages: pagy.pages
      }
    }
  end

  def show
    car = Car.includes(:car_images, :user).find(params[:id])
    render json: car_response(car)
  end

  def create
    car = current_user.cars.build(car_params)

    image_list = params[:car_images] || params[:images]
    if image_list.present?
      image_list.each_with_index do |image, i|
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

    # Обновление custom_fields
    if params[:custom_fields].present?
      new_fields = params[:custom_fields].to_unsafe_h
      car.custom_fields ||= {}
      car.custom_fields.merge!(new_fields)
    end

    # Обновление позиций и добавление новых car_images
    if params[:image_positions].present?
      image_positions = JSON.parse(params[:image_positions])
      new_files = params[:car_images] || []
      new_file_index = 0

      total_count = car.car_images.count + new_files.size
      if total_count > 25
        return render json: { error: "Можно загрузить не более 25 изображений" }, status: :unprocessable_entity
      end

      image_positions.each do |entry|
        if entry["id"].present?
          image = car.car_images.find_by(id: entry["id"])
          image&.update(position: entry["position"])
        else
          file = new_files[new_file_index]
          new_file_index += 1

          car.car_images.create!(
            image: file,
            position: entry["position"]
          )
        end
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
      :category,
      :has_air_conditioner,
      custom_fields: {},
      images: []
    )
  end

  def car_response(car)
    CarSerializer.call(car)
  end
end
