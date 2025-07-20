require "shrine"
require "shrine/storage/file_system"

Shrine.storages = {
  cache: Shrine::Storage::FileSystem.new("public", prefix: "uploads/cache"), # временное
  store: Shrine::Storage::FileSystem.new("public", prefix: "uploads/store"), # постоянное
}
Shrine.plugin :derivation_endpoint, secret_key: Rails.application.secret_key_base

Shrine.plugin :activerecord
Shrine.plugin :cached_attachment_data
Shrine.plugin :restore_cached_data
Shrine.plugin :derivatives
Shrine.plugin :validation_helpers
Shrine.plugin :pretty_location
Shrine.plugin :instrumentation
Shrine.plugin :upload_endpoint

# Configuration for URL generation
host = ENV.fetch("APP_HOST", "localhost:3000")
protocol = host.include?("localhost") ? "http" : "https"
full_host = "#{protocol}://#{host}"

# Для compatibility с API prefix
Shrine.plugin :url_options, store: { host: full_host, prefix: "/api" }

Shrine.logger = Rails.logger

