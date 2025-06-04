class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, :registerable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :cars, dependent: :destroy

  enum :role, { client: 0, owner: 1 }
  validates :role, presence: true
end
