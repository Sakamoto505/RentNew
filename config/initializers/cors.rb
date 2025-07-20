# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'https://rentavtokavkaz.ru',
            /https?:\/\/localhost(?::\d+)?/,
            /https?:\/\/\d{1,3}(?:\.\d{1,3}){3}(?::\d+)?/

    resource '/api/*',
             headers: :any,
             expose: ['Authorization'],
             methods: [:get, :post, :patch, :put, :delete, :options],
             credentials: true
  end
  
  allow do
    origins '*'
    
    resource '/api/*',
             headers: :any,
             expose: ['Authorization'],
             methods: [:get, :post, :patch, :put, :delete, :options],
             credentials: false
  end
end
