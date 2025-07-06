# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Allow requests from specific origins with credentials
    origins 'http://localhost:5175', 'https://rentavtokavkaz.ru'

    resource '/api/*',
             headers: :any,
             expose: ['Authorization'],
             methods: [:get, :post, :patch, :put, :delete, :options],
             credentials: true
  end
end
