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

Rails.logger.info "=== SHRINE URL CONFIG ==="
Rails.logger.info "APP_HOST env: #{ENV['APP_HOST']}"
Rails.logger.info "Resolved host: #{host}"
Rails.logger.info "Full host: #{full_host}"
Rails.logger.info "=========================="

puts "=== SHRINE URL CONFIG (PUTS) ==="
puts "APP_HOST env: #{ENV['APP_HOST']}"
puts "Resolved host: #{host}"
puts "Full_host: #{full_host}"
puts "================================="

# Для compatibility с API prefix - попробуем другой подход
Shrine.plugin :url_options, store: { host: full_host }, cache: { host: full_host }

# Переопределим метод url для добавления /api префикса
Shrine::UploadedFile.class_eval do
  alias_method :original_url, :url
  
  def url(**options)
    original_url = self.original_url(**options)
    if original_url && !original_url.start_with?('http')
      # Относительный URL - добавляем хост и префикс
      host = ENV.fetch("APP_HOST", "localhost:3000")
      protocol = host.include?("localhost") ? "http" : "https"
      "#{protocol}://#{host}/api#{original_url}"
    elsif original_url && original_url.include?(ENV.fetch("APP_HOST", "localhost:3000"))
      # Абсолютный URL с нашим хостом - добавляем /api префикс если его нет
      original_url.gsub("#{ENV.fetch("APP_HOST", "localhost:3000")}/uploads", "#{ENV.fetch("APP_HOST", "localhost:3000")}/api/uploads")
    else
      original_url
    end
  end
end

Shrine.logger = Rails.logger

