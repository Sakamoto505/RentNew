class CompanyLogo < ApplicationRecord
  include ImageUploader::Attachment(:image)
  belongs_to :user

  def image_url
    image.url
  end
end
