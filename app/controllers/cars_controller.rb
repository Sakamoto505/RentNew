class CarsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :bulk_show, :total_count, :cars_for_sitemap]

  def index
    cars = Car.includes(:car_images, :user).order(created_at: :desc).distinct

    # === Поиск по title ===
    if (search = params[:search].presence)
      cars = cars.search_by_title(search)
    end

    # === Фильтр по региону ===
    if (region = params[:region].presence)
      cars = cars.joins(:user).where(users: { region: region })
    end

    # === Фильтр по категории (enum) ===
    if (category = params[:category].presence)
      key = category.to_s.strip.downcase
      if Car.categories.key?(key)
        cars = cars.where(category: Car.categories[key]) # enum как integer
        category_mode = true
      else
        cars = Car.none
        category_mode = true
      end
    end

    # === Пагинация ===
    per_page =
      if category_mode
        12
      else
        (params[:per_page].presence || 12).to_i.clamp(1, 100)
      end

    # === Отладка пагинации ===
    total_cars = cars.count
    all_car_ids = cars.pluck(:id)
    Rails.logger.info "=== PAGINATION DEBUG ==="
    Rails.logger.info "Total cars query: #{total_cars}"
    Rails.logger.info "All car IDs: #{all_car_ids}"
    Rails.logger.info "Requested page: #{params[:page] || 1}, per_page: #{per_page}"

    pagy, records = pagy(cars, items: per_page)

    Rails.logger.info "Pagy page: #{pagy.page}, count: #{pagy.count}, pages: #{pagy.pages}"
    Rails.logger.info "Records returned: #{records.count}"
    Rails.logger.info "Record IDs: #{records.pluck(:id)}"
    Rails.logger.info "========================="

    # === Формирование ответа только из records ===
    cars_json = records.map { |car| car_response(car) }

    # Анти-кэш (чтобы не увидеть старый ответ)
    response.set_header("Cache-Control", "no-store, max-age=0, must-revalidate")

    render json: {
      cars: cars_json,
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

  def destroy
    car = current_user.cars.find(params[:id])
    car.destroy!
    render json: { message: "Автомобиль успешно удален" }, status: :ok
  end



  def my_cars
    cars = current_user.cars.includes(:car_images, :user)
    render json: cars.map { |car| car_response(car) }
  end

  def bulk_show
    car_ids = params[:ids]

    if car_ids.blank?
      return render json: { error: 'Параметр ids обязателен' }, status: :bad_request
    end

    # Преобразуем в массив если не массив
    ids_array = car_ids.is_a?(Array) ? car_ids : [car_ids].flatten

    cars = Car.includes(:car_images, :user).where(id: ids_array)

    render json: {
      cars: cars.map { |car| car_response(car) },
      meta: {
        requested: ids_array.length,
        found: cars.length,
        missing_ids: ids_array.map(&:to_i) - cars.pluck(:id)
      }
    }
  end

  def total_count
    render json: { total_cars_count: Car.count }
  end

  def cars_for_sitemap
    cars = Car.includes(:car_images).select(:id, :slug, :title, :updated_at, :location)
    
    render json: {
      cars: cars.map do |car|
        main_image = car.car_images.order(:position).first
        {
          id: car.id,
          slug: car.slug,
          title: car.title,
          updated_at: car.updated_at,
          main_image_url: main_image&.image_url,
          location: car.location
        }
      end
    }
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
      :driver_only,
      custom_fields: {},
      images: []
    )
  end

  def car_response(car)
    CarSerializer.call(car)
  end
end
