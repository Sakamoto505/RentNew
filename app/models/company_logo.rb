class CompanyLogo < ApplicationRecord
  include ImageUploader::Attachment(:image)
  belongs_to :user

  def image_url
    url = image.url
    Rails.logger.info "CompanyLogo image_url: #{url}"

    if url && !url.start_with?('http')
      full_url = "https://rentavtokavkaz.ru/api#{url}"
      Rails.logger.info "Full URL: #{full_url}"
      return full_url
    end
    
    url
  end
end
