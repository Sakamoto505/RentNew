class CompaniesListController < ApplicationController
  def index
    companies = User.company.order(:company_name)
    
    render json: companies.map { |company|
      {
        id: company.id,
        company_name: company.company_name,
        email: company.email,
        is_partner_verified: company.is_partner_verified || false,
        created_at: company.created_at.iso8601
      }
    }
  end
end