class ImageUploader < Shrine
  plugin :validation_helpers
  plugin :processing
  plugin :derivatives

  Attacher.validate do
    validate_max_size 8*1024*1024, message: "максимум 8 МБ"
    validate_mime_type_inclusion ["image/jpeg", "image/png", "image/webp"]
  end

  process(:store) do |io, context:|
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
    
    # Read the original size
    io.rewind
    original_content = io.read
    original_size = original_content.bytesize
    
    return io if original_size <= max_size
    
    # Reset io position
    io.rewind
    
    # Start with the specified quality and try to compress
    current_quality = quality
    
    # Try different compression levels
    5.times do
      begin
        processed_io = ImageProcessing::MiniMagick
          .source(io)
          .resize_to_limit(2048, 2048)
          .quality(current_quality)
          .call
        
        if processed_io.size <= max_size
          return processed_io
        end
        
        break if current_quality <= 30
        current_quality -= 10
        io.rewind
      rescue => e
        Rails.logger.error "Image compression error: #{e.message}"
        return io
      end
    end
    
    # If we couldn't compress enough, return the last attempt
    processed_io || io
  end
end
