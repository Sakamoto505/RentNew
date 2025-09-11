class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  include ImageUploader::Attachment(:company_avatar)

  REGION_NAMES = {
    dagestan: "Республика Дагестан",
    ingushetia: "Республика Ингушетия",
    kabardino_balkaria: "Кабардино-Балкарская Республика",
    karachay_cherkessia: "Карачаево-Черкесская Республика",
    north_ossetia: "Республика Северная Осетия — Алания",
    chechnya: "Чеченская Республика",
    stavropol_krai: "Ставропольский край",
    adygea: "Республика Адыгея",
    kalmykia: "Республика Калмыкия",
    krasnodar_krai: "Краснодарский край",
    astrakhan_oblast: "Астраханская область",
    volgograd_oblast: "Волгоградская область",
    rostov_oblast: "Ростовская область",
    crimea: "Республика Крым",
    sevastopol: "Город Севастополь"
  }.freeze

  def city_name
    REGION_NAMES[region&.to_sym]
  end


  has_many :company_logos, dependent: :destroy
  accepts_nested_attributes_for :company_logos, allow_destroy: true

  devise :database_authenticatable, :registerable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :cars, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorite_cars, through: :favorites, source: :car
  has_many :subscriptions, foreign_key: :company_id, dependent: :destroy
  enum :role, { client: 0, company: 1, admin: 2 }
  validates :role, presence: true
  validates :company_name, presence: true, uniqueness: true, if: :company?
  validates :region, presence: true, if: :company?
  validates :phone_1, presence: true, if: :company?
  validates :region, inclusion: { in: REGION_NAMES.keys.map(&:to_s) }, if: -> { region.present? }

  def update_role_based_on_cars
    car_count = cars.reload.count

    if car_count > 3
      update_column(:role, :company) unless company?
    else
      update_column(:role, :client) unless client?
    end
  end

  def total_active_slots(date = Date.current)
    return 0 unless company?
    Subscription.total_active_slots_for_company(id, date)
  end

  def has_dedicated_site?(date = Date.current)
    return false unless company?
    Subscription.has_active_dedicated_site?(id, date)
  end

  def active_subscriptions(date = Date.current)
    return Subscription.none unless company?
    Subscription.active_subscriptions_for_company(id, date)
  end

  def can_add_car?
    return true if has_dedicated_site?
    
    current_car_count = cars.count
    available_slots = total_active_slots
    
    current_car_count < available_slots
  end

  def remaining_slots
    return Float::INFINITY if has_dedicated_site?
    
    current_car_count = cars.count
    available_slots = total_active_slots
    
    [available_slots - current_car_count, 0].max
  end
end
