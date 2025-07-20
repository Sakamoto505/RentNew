class CompanyLogo < ApplicationRecord
  include ImageUploader::Attachment(:image)
  belongs_to :user

  def image_url
    return nil unless image.present?
    
    url = image.url
    Rails.logger.info "CompanyLogo#image_url: #{url}"
    url
  end
end
