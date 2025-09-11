class Subscription < ApplicationRecord
  belongs_to :user, foreign_key: :company_id

  enum :plan, { 
    dedicated_site: 'dedicated_site', 
    slots: 'slots' 
  }

  validates :company_id, presence: true
  validates :plan, presence: true
  validates :starts_at, presence: true
  validates :ends_at, presence: true
  validates :is_active, inclusion: { in: [true, false] }
  validates :qty, presence: true, numericality: { greater_than: 0 }, if: :slots?

  validate :end_date_after_start_date

  scope :active, -> { where(is_active: true) }
  scope :current, -> { where('starts_at <= ? AND ends_at >= ?', Date.current, Date.current) }
  scope :for_company, ->(company_id) { where(company_id: company_id) }
  scope :slots_plan, -> { where(plan: 'slots') }
  scope :dedicated_site_plan, -> { where(plan: 'dedicated_site') }

  def self.total_active_slots_for_company(company_id, date = Date.current)
    for_company(company_id)
      .slots_plan
      .active
      .where('starts_at <= ? AND ends_at >= ?', date, date)
      .sum(:qty)
  end

  def self.has_active_dedicated_site?(company_id, date = Date.current)
    for_company(company_id)
      .dedicated_site_plan
      .active
      .where('starts_at <= ? AND ends_at >= ?', date, date)
      .exists?
  end

  def self.active_subscriptions_for_company(company_id, date = Date.current)
    for_company(company_id)
      .active
      .where('starts_at <= ? AND ends_at >= ?', date, date)
  end

  def active?
    is_active && starts_at <= Date.current && ends_at >= Date.current
  end

  def expired?
    ends_at < Date.current
  end

  def pending?
    starts_at > Date.current
  end

  private

  def end_date_after_start_date
    return unless starts_at.present? && ends_at.present?
    
    if ends_at <= starts_at
      errors.add(:ends_at, 'должна быть позже даты начала')
    end
  end
end