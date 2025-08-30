require "shrine"
require "shrine/storage/file_system"

Shrine.storages = {
  cache: Shrine::Storage::FileSystem.new("public", prefix: "uploads/cache"),
  store: Shrine::Storage::FileSystem.new("public", prefix: "uploads/store"),
}

puts "=== SHRINE STORAGE DEBUG ==="
puts "Rails.root: #{Rails.root}"
puts "Cache storage path: #{File.join(Rails.root, 'public', 'uploads', 'cache')}"
puts "Store storage path: #{File.join(Rails.root, 'public', 'uploads', 'store')}"
puts "Time: #{Time.current}"
puts "============================="

# Проверим, что папки существуют
cache_dir = File.join(Rails.root, 'public', 'uploads', 'cache')
store_dir = File.join(Rails.root, 'public', 'uploads', 'store')

FileUtils.mkdir_p(cache_dir) unless Dir.exist?(cache_dir)
FileUtils.mkdir_p(store_dir) unless Dir.exist?(store_dir)

puts "Cache dir exists: #{Dir.exist?(cache_dir)}"
puts "Store dir exists: #{Dir.exist?(store_dir)}"

Shrine.plugin :activerecord
Shrine.plugin :cached_attachment_data
Shrine.plugin :restore_cached_data
Shrine.plugin :derivatives
Shrine.plugin :validation_helpers
Shrine.plugin :pretty_location
Shrine.plugin :instrumentation
Shrine.plugin :processing

# URLs will be relative paths without domain
# host = ENV.fetch("APP_HOST", "rentavtokavkaz.ru")
# Shrine.plugin :url_options, store: {
#   host: "https://#{host}"
# }, cache: {
#   host: "https://#{host}"
# }