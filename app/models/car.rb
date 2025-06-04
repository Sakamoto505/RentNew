class Car < ApplicationRecord
  belongs_to :user

  enum :category, {
    economy: 'economy',
    comfort: 'comfort',
    business: 'business',
    premium: 'premium',
    suv: 'suv',
    minivan: 'minivan',
    electric: 'electric'
  }

  validates :title, :price, :location, presence: true


end
