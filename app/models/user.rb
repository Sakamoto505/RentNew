class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  include ImageUploader::Attachment(:company_avatar)

  has_many :company_logos, dependent: :destroy
  accepts_nested_attributes_for :company_logos, allow_destroy: true

  devise :database_authenticatable, :registerable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :cars, dependent: :destroy

  enum :role, { client: 0, owner: 1 }
  validates :role, presence: true
  validates :company_name, presence: true, if: -> { owner? }

  def update_role_based_on_cars
    if cars.count > 3
      update_column(:role, :owner) unless owner?
    else
      update_column(:role, :client) unless client?
    end
  end
end
