class Car < ApplicationRecord
  belongs_to :user
  has_many :car_images, dependent: :destroy
  accepts_nested_attributes_for :car_images, allow_destroy: true

  enum :category, {
    economy: 'economy',
    comfort: 'comfort',
    business: 'business',
    premium: 'premium',
    suv: 'suv',
    minivan: 'minivan',
    electric: 'electric'
  }

  # validates :title, :price, :location, presence: true


end
