# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'

    resource '/api/*',
             headers: :any,
             expose: ['Authorization'],
             methods: [:get, :post, :patch, :put, :delete, :options],
             credentials: false
  end
end
