class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin!

  def update_verification
    user = User.find(params[:user_id])
    
    verification_params = params.permit(:is_partner_verified, :is_phone_verified)
    
    if user.update(verification_params)
      render json: {
        message: 'Верификация обновлена',
        user: {
          id: user.id,
          email: user.email,
          company_name: user.company_name,
          is_partner_verified: user.is_partner_verified,
          is_phone_verified: user.is_phone_verified
        }
      }
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def ensure_admin!
    unless current_user.admin?
      render json: { error: 'Доступ запрещен' }, status: :forbidden
    end
  end
end