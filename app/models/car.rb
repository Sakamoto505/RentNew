class Car < ApplicationRecord
  belongs_to :user
  has_many :car_images, dependent: :destroy
  accepts_nested_attributes_for :car_images, allow_destroy: true

  after_create :recalculate_user_role
  after_destroy :recalculate_user_role
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
  def recalculate_user_role
    user.update_role_based_on_cars
  end

end
