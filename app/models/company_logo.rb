class CompanyLogo < ApplicationRecord
  include ImageUploader::Attachment(:image)
  belongs_to :user

  def image_url
    return nil unless image.present?
    
    url = image.url
    file_path = image.file_path if image.respond_to?(:file_path)
    storage_key = image.storage_key if image.respond_to?(:storage_key)
    
    Rails.logger.info "=== CompanyLogo#image_url DEBUG ==="
    Rails.logger.info "Generated URL: #{url}"
    Rails.logger.info "File path: #{file_path}"
    Rails.logger.info "Storage: #{image.storage.class.name}"
    Rails.logger.info "Storage directory: #{image.storage.directory}" if image.storage.respond_to?(:directory)
    Rails.logger.info "Image data: #{image_data}"
    Rails.logger.info "==================================="
    
    url
  end
end
