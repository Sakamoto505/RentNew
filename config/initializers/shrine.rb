require "shrine"
require "shrine/storage/file_system"

Shrine.storages = {
  cache: Shrine::Storage::FileSystem.new("public", prefix: "uploads/cache"),
  store: Shrine::Storage::FileSystem.new("public", prefix: "uploads/store"),
}

Shrine.plugin :activerecord
Shrine.plugin :cached_attachment_data
Shrine.plugin :restore_cached_data
Shrine.plugin :derivatives
Shrine.plugin :validation_helpers
Shrine.plugin :pretty_location
Shrine.plugin :instrumentation

# Простая конфигурация URL без переопределения
host = ENV.fetch("APP_HOST", "rentavtokavkaz.ru")
Shrine.plugin :url_options, store: { 
  host: "https://#{host}", 
  prefix: "/api/uploads/store" 
}, cache: { 
  host: "https://#{host}", 
  prefix: "/api/uploads/cache" 
}