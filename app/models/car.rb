class Car < ApplicationRecord
  belongs_to :user
  has_many :car_images, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorited_by, through: :favorites, source: :user
  accepts_nested_attributes_for :car_images, allow_destroy: true

  after_create :recalculate_user_role
  after_destroy :recalculate_user_role
  before_save :generate_slug
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

  private

  def generate_slug
    return if title.blank? || location.blank?
    
    # Очищаем title от спецсимволов и приводим к нижнему регистру
    clean_title = title.downcase
                      .gsub(/[^\p{L}\p{N}\s-]/, '') # Удаляем все кроме букв, цифр, пробелов и дефисов
                      .gsub(/\s+/, '-') # Заменяем пробелы на дефисы
                      .gsub(/-+/, '-') # Убираем множественные дефисы
                      .gsub(/^-+|-+$/, '') # Убираем дефисы в начале и конце
    
    # Очищаем location, убираем г. если есть
    clean_location = location.downcase
                            .gsub(/^г\.?\s*/, '') # Убираем "г." или "г" в начале
                            .gsub(/[^\p{L}\p{N}\s-]/, '') # Удаляем спецсимволы
                            .gsub(/\s+/, '-') # Заменяем пробелы на дефисы
                            .gsub(/^-+|-+$/, '') # Убираем дефисы в начале и конце
    
    # Формируем slug: title-location-id
    base_slug = "#{clean_title}-#{clean_location}-#{id || 'new'}"
    
    self.slug = base_slug
  end

end
