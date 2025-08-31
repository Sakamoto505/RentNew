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
    
    if record.is_a?(User) && name == :company_avatar
      # Avatar compression to ~100kb
      Rails.logger.info "Compressing avatar to ~100kb"
      compress_image(io, max_size: 80 * 1024, quality: 60)
    elsif record.is_a?(CarImage)
      # Car photos compression with watermark
      Rails.logger.info "Compressing car photo with watermark to ~450kb"
      compress_and_watermark_car_image(io, max_size: 450 * 1024, quality: 85)
    elsif record.is_a?(CompanyLogo)
      # Company photos compression to 400-500kb
      Rails.logger.info "Compressing company photo to ~450kb"
      compress_image(io, max_size: 450 * 1024, quality: 85)
    else
      # Default compression for all other images
      Rails.logger.info "Applying default compression to ~450kb"
      compress_image(io, max_size: 450 * 1024, quality: 85)
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

  def compress_and_watermark_car_image(io, max_size:, quality:)
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
          .call do |magick|
            magick.font_family "Arial"
            magick.font_size "30"
            magick.fill "rgba(255,255,255,0.8)"
            magick.stroke "rgba(0,0,0,0.5)"
            magick.stroke_width "1"
            magick.gravity "SouthEast"
            magick.annotate "+20+20", "rentavtokavkaz"
          end
        
        Rails.logger.info "Compressed car image with watermark: quality=#{current_quality}, size=#{processed_io.size} bytes, target=#{max_size} bytes"
        
        if processed_io.size <= max_size
          return processed_io
        end
        
        break if current_quality <= 20
        current_quality -= 10
      rescue => e
        Rails.logger.error "Car image compression/watermark error: #{e.message}"
        io.rewind
        return compress_image(io, max_size: max_size, quality: quality)
      end
    end
    
    # Return compressed version even if it's still larger than target
    processed_io || io
  end
end
