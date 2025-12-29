# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'https://rentavtokavkaz.ru',
            'https://www.rentavtokavkaz.ru',
            'http://rentavtokavkaz.ru',
            'http://www.rentavtokavkaz.ru',
            /https?:\/\/localhost(?::\d+)?/,
            /https?:\/\/\d{1,3}(?:\.\d{1,3}){3}(?::\d+)?/

    resource '*',
             headers: :any,
             expose: ['Authorization'],
             methods: [:get, :post, :patch, :put, :delete, :options],
             credentials: true
  end
end
