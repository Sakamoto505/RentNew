class Admin::AdminPanelController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin!

  def companies
    companies = User.company.order(created_at: :desc)
    
    render json: {
      total: companies.count,
      companies: companies.map do |company|
        {
          id: company.id,
          company_name: company.company_name,
          email: company.email,
          region: company.city_name,
          phone_1: company.phone_1,
          phone_2: company.phone_2,
          is_partner_verified: company.is_partner_verified || false,
          is_phone_verified: company.is_phone_verified || false,
          role: company.role,
          cars_count: company.cars.count,
          created_at: company.created_at.iso8601,
          updated_at: company.updated_at.iso8601
        }
      end
    }
  end

  def show_company
    company = User.find(params[:id])
    
    render json: {
      id: company.id,
      company_name: company.company_name,
      email: company.email,
      region: company.city_name,
      phone_1: company.phone_1,
      phone_2: company.phone_2,
      is_partner_verified: company.is_partner_verified || false,
      is_phone_verified: company.is_phone_verified || false,
      role: company.role,
      cars_count: company.cars.count,
      created_at: company.created_at.iso8601,
      updated_at: company.updated_at.iso8601,
      cars: company.cars.map { |car|
        {
          id: car.id,
          brand: car.brand,
          model: car.model,
          year: car.year,
          created_at: car.created_at.iso8601
        }
      }
    }
  end

  def update_company
    company = User.find(params[:id])
    
    if company.update(company_params)
      render json: {
        message: 'Верификация обновлена',
        company: {
          id: company.id,
          company_name: company.company_name,
          email: company.email,
          is_partner_verified: company.is_partner_verified,
          is_phone_verified: company.is_phone_verified,
          updated_at: company.updated_at.iso8601
        }
      }
    else
      render json: { 
        error: 'Ошибка обновления',
        errors: company.errors.full_messages 
      }, status: :unprocessable_entity
    end
  end

  def credentials
    users = User.all.order(created_at: :desc)
    
    render json: {
      total: users.count,
      users: users.map do |user|
        {
          id: user.id,
          email: user.email,
          role: user.role,
          company_name: user.company_name,
          encrypted_password: user.encrypted_password,
          created_at: user.created_at.iso8601,
          current_sign_in_at: user.current_sign_in_at&.iso8601,
          last_sign_in_at: user.last_sign_in_at&.iso8601,
          sign_in_count: user.sign_in_count || 0
        }
      end
    }
  end

  private

  def ensure_admin!
    unless current_user.admin?
      render json: { error: 'Доступ запрещен. Только для администраторов.' }, status: :forbidden
    end
  end

  def company_params
    params.permit(:is_partner_verified, :is_phone_verified)
  end
end