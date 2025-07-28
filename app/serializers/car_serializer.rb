# app/serializers/car_serializer.rb
module CarSerializer
  def self.call(car)
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
      custom_fields: (car.custom_fields || {}).map { |k, v| { key: k, value: v } },
      contacts: {
        phone_1: user.phone_1,
        phone_2: user.phone_2,
        whatsapp: user.whatsapp,
        telegram: user.telegram,
        instagram: user.instagram,
        website: user.website,
        region: user.region
      }
    }
  end
end
