class ImageUploader < Shrine
  plugin :validation_helpers
  plugin :processing
  plugin :derivatives

  Attacher.validate do
    validate_max_size 8*1024*1024, message: "максимум 8 МБ"
    validate_mime_type_inclusion ["image/jpeg", "image/png", "image/webp"]
  end

  process(:cache) do |io, **options|
    context = options[:context] || {}
    record = context[:record]
    name = context[:name]

    Rails.logger.info "ImageUploader cache processing: record=#{record&.class}, name=#{name}, io=#{io.class}"
    Rails.logger.info "Context inspect: #{context.inspect}"

    # Check location to determine image type
    location = options[:location] || context[:location] || ""
    Rails.logger.info "Location: #{location}"

    if name == :company_avatar
      # Avatar compression to ~100kb
      Rails.logger.info "Compressing avatar to ~100kb"
      compress_image(io, max_size: 100 * 1024, quality: 75)
    elsif location.include?("carimage") || record.is_a?(CarImage)
      # Car photos compression to 400-500kb
      Rails.logger.info "Compressing car photo to ~450kb"
      compress_image(io, max_size: 450 * 1024, quality: 85)
    else
      # Company logo compression (default for company_logos uploads)
      Rails.logger.info "Compressing company logo to ~80kb"
      compress_logo_image(io, max_size: 80 * 1024, quality: 45)
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
          .format("jpeg")
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

  def compress_logo_image(io, max_size:, quality:)
    require "image_processing/mini_magick"
    
    io.rewind
    current_quality = quality
    processed_io = nil
    
    # Try different compression levels with smaller resolution for logos
    8.times do
      begin
        io.rewind
        processed_io = ImageProcessing::MiniMagick
          .source(io)
          .resize_to_limit(800, 800)  # Smaller resolution for logos
          .quality(current_quality)
          .format("jpeg")
          .call
        
        Rails.logger.info "Compressed logo: quality=#{current_quality}, size=#{processed_io.size} bytes, target=#{max_size} bytes"
        
        if processed_io.size <= max_size
          return processed_io
        end
        
        break if current_quality <= 15
        current_quality -= 5
      rescue => e
        Rails.logger.error "Logo compression error: #{e.message}"
        io.rewind
        return io
      end
    end
    
    # Return compressed version even if it's still larger than target
    processed_io || io
  end
end