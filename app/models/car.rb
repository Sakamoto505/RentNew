class Car < ApplicationRecord
  belongs_to :user
  has_many :car_images, dependent: :destroy
  has_many :favorites
  has_many :favorited_by, through: :favorites, source: :user
  accepts_nested_attributes_for :car_images, allow_destroy: true

  after_create :recalculate_user_role
  after_destroy :recalculate_user_role
  enum :category, {
    mid: 'mid',
    russian: 'russian',
    suv: 'suv',
    cabrio: 'cabrio',
    sport: 'sport',
    premium: 'premium',
    electric: 'electric',
    minivan: 'minivan',
    bike: 'bike',
  }

  # validates :title, :price, :location, presence: true

  # Простой поиск по title
  scope :search_by_title, ->(query) {
    return all if query.blank?
    where("title ILIKE ?", "%#{query}%")
  }

  def recalculate_user_role
    user.update_role_based_on_cars
  end

end
