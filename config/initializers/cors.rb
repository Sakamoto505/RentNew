# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins do |origin, env|
      origin
    end

    resource '/api/*',
             headers: :any,
             expose: ['Authorization'],
             methods: [:get, :post, :patch, :put, :delete, :options],
             credentials: true
  end
end
