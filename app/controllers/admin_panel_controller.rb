class AdminPanelController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin!

  def index
    @companies = User.company.order(created_at: :desc)
  end

  def show
    @company = User.find(params[:id])
  end

  def edit
    @company = User.find(params[:id])
  end

  def update
    @company = User.find(params[:id])
    
    if @company.update(company_params)
      redirect_to admin_panel_path(@company), notice: 'Компания обновлена'
    else
      render :edit
    end
  end

  def credentials
    @users = User.all.order(created_at: :desc)
  end

  private

  def ensure_admin!
    unless current_user.admin?
      redirect_to root_path, alert: 'Доступ запрещен'
    end
  end

  def company_params
    params.require(:user).permit(:is_partner_verified, :is_phone_verified)
  end
end