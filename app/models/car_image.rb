class CarImage < ApplicationRecord
  include ImageUploader::Attachment(:image)

  belongs_to :car
  validates :image, presence: true

  def image_url
    return nil unless image.present?
    
    url = image.url
    Rails.logger.info "CarImage#image_url: #{url}"
    url
  end
end
