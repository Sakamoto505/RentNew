class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  include ImageUploader::Attachment(:company_avatar)

  has_many :company_logos, dependent: :destroy
  accepts_nested_attributes_for :company_logos, allow_destroy: true

  devise :database_authenticatable, :registerable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :cars, dependent: :destroy

  enum :role, { client: 0, company: 1 }
  validates :role, presence: true
  validates :company_name, presence: true, if: -> { company }

  def update_role_based_on_cars
    car_count = cars.reload.count

    if car_count > 3
      update_column(:role, :company) unless company?
    else
      update_column(:role, :client) unless client?
    end
  end
end
