class CompanyLogosController < ApplicationController
  before_action :authenticate_user!

  def destroy
    logo = current_user.company_logos.find_by(id: params[:id])

    if logo
      logo.destroy
      render json: { status: 'ok', message: 'Логотип удалён' }
    else
      render json: { error: 'Логотип не найден' }, status: :not_found
    end
  end
end
