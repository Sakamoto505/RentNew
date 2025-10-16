class BlacklistEntry < ApplicationRecord
  belongs_to :company, class_name: 'User'

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :birth_year, presence: true, numericality: { greater_than: 1900, less_than_or_equal_to: Date.current.year }
  validates :dl_number, presence: true
  validates :reason, presence: true

  scope :search_by_query, ->(query) {
    return all if query.blank?
    
    search_terms = query.strip.split(/\s+/)
    conditions = search_terms.map do |term|
      sanitized_term = "%#{sanitize_sql_like(term)}%"
      "(first_name ILIKE ? OR last_name ILIKE ? OR dl_number ILIKE ?)"
    end.join(' AND ')
    
    values = search_terms.flat_map { |term| ["%#{sanitize_sql_like(term)}%"] * 3 }
    where(conditions, *values)
  }

  def full_name
    "#{first_name} #{last_name}"
  end

  def company_avatar
    company.company_avatar_url if company&.company_avatar
  end
end