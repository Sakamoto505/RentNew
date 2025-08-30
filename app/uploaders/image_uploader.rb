Float class ImageUploader < Shrine
  plugin :validation_helpers
  plugin :processing
  plugin :derivatives

  Attacher.validate do
    validate_max_size 8*1024*1024, message: "максимум 8 МБ"
    validate_mime_type_inclusion ["image/jpeg", "image/png", "image/webp"]
  end

  process(:store) do |io, **options|
    context = options[:context] || {}
    record = context[:record]
    name = context[:name]

    if record.is_a?(User) && name == :company_avatar
      # Avatar compression to ~100kb
      compress_image(io, max_size: 100 * 1024, quality: 75)
    elsif record.is_a?(CarImage) || record.is_a?(CompanyLogo)
      # Company photos and car photos compression to 400-500kb
      compress_image(io, max_size: 450 * 1024, quality: 85)
    else
      io
    end
  end

  private

  def compress_image(io, max_size:, quality:)
    require "image_processing/mini_magick"

    io.rewind
    current_quality = quality
    processed_io = nil

    # Try different compression levels until we reach target size
    8.times do
      begin
        io.rewind
        processed_io = ImageProcessing::MiniMagick
          .source(io)
          .resize_to_limit(1920, 1920)
          .quality(current_quality)
          .convert("jpg")
          .call

        Rails.logger.info "Compressed image: quality=#{current_quality}, size=#{processed_io.size} bytes, target=#{max_size} bytes"

        if processed_io.size <= max_size
          return processed_io
        end

        break if current_quality <= 20
        current_quality -= 10
      rescue => e
        Rails.logger.error "Image compression error: #{e.message}"
        io.rewind
        return io
      end
    end

    # Return compressed version even if it's still larger than target
    processed_io || io
  end
end
