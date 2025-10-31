class BlacklistController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_partner_verified, except: [:search]
  before_action :set_blacklist_entry, only: [:destroy]

  def create
    @blacklist_entry = current_user.blacklist_entries.build(blacklist_entry_params)
    
    if @blacklist_entry.save
      render json: serialize_blacklist_entry(@blacklist_entry), status: :created
    else
      render json: { errors: @blacklist_entry.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def mine
    @blacklist_entries = current_user.blacklist_entries.order(created_at: :desc)
    render json: @blacklist_entries.map { |entry| serialize_blacklist_entry_for_mine(entry) }
  end

  def search
    @blacklist_entries = BlacklistEntry.includes(:company)
                                      .search_by_query(params[:query])
                                      .order(created_at: :desc)
    
    render json: @blacklist_entries.map { |entry| serialize_blacklist_entry_for_search(entry) }
  end

  def destroy
    if @blacklist_entry.destroy
      head :no_content
    else
      render json: { errors: ['Не удалось удалить запись'] }, status: :unprocessable_entity
    end
  end

  private

  def blacklist_entry_params
    params.require(:blacklist_entry).permit(:first_name, :last_name, :birth_year, :dl_number, :reason)
  end

  def set_blacklist_entry
    @blacklist_entry = current_user.blacklist_entries.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Запись не найдена' }, status: :not_found
  end

  def ensure_partner_verified
    unless current_user.is_partner_verified?
      render json: { error: 'Доступ запрещен. Компания не верифицирована' }, status: :forbidden
    end
  end

  def serialize_blacklist_entry(entry)
    {
      id: entry.id,
      firstName: entry.first_name,
      lastName: entry.last_name,
      birthYear: entry.birth_year,
      dlNumber: entry.dl_number,
      reason: entry.reason,
      createdAt: entry.created_at.iso8601
    }
  end

  def serialize_blacklist_entry_for_mine(entry)
    serialize_blacklist_entry(entry)
  end

  def serialize_blacklist_entry_for_search(entry)
    serialize_blacklist_entry(entry).merge(
      companyId: entry.company_id,
      companyName: entry.company.company_name,
      companyAvatar: entry.company_avatar || ""
    )
  end
end