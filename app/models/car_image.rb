class CarImage < ApplicationRecord
  include ImageUploader::Attachment(:image)

  belongs_to :car
  validates :image, presence: true
end
