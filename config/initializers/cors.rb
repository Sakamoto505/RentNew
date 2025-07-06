# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins lambda { |origin, _env| origin }

    resource '/api/*',
             headers: :any,
             expose: ['Authorization'],
             methods: [:get, :post, :patch, :put, :delete, :options],
             credentials: true
  end
end
