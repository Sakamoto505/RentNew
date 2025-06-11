class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  include ImageUploader::Attachment(:company_logo)

  devise :database_authenticatable, :registerable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :cars, dependent: :destroy

  enum :role, { client: 0, owner: 1 }
  validates :role, presence: true
  validates :company_name, presence: true, if: -> { owner? }

end
