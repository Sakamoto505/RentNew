class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_subscription, only: [:show, :update, :destroy]

  def index
    @subscriptions = Subscription.for_company(current_user.id)
                                .includes(:user)
                                .order(created_at: :desc)
    
    render json: {
      subscriptions: @subscriptions.map { |s| subscription_json(s) }
    }
  end

  def show
    render json: { subscription: subscription_json(@subscription) }
  end

  def create
    @subscription = Subscription.new(subscription_params)
    @subscription.company_id = current_user.id

    if @subscription.save
      render json: { 
        subscription: subscription_json(@subscription),
        message: 'Подписка успешно создана'
      }, status: :created
    else
      render json: { 
        errors: @subscription.errors.full_messages 
      }, status: :unprocessable_entity
    end
  end

  def update
    if @subscription.update(subscription_params)
      render json: { 
        subscription: subscription_json(@subscription),
        message: 'Подписка успешно обновлена'
      }
    else
      render json: { 
        errors: @subscription.errors.full_messages 
      }, status: :unprocessable_entity
    end
  end

  def destroy
    @subscription.destroy
    render json: { message: 'Подписка удалена' }
  end

  def current_status
    company_id = current_user.id
    
    render json: {
      total_slots: Subscription.total_active_slots_for_company(company_id),
      has_dedicated_site: Subscription.has_active_dedicated_site?(company_id),
      active_subscriptions: Subscription.active_subscriptions_for_company(company_id)
                                      .map { |s| subscription_json(s) }
    }
  end

  private

  def set_subscription
    @subscription = Subscription.for_company(current_user.id).find(params[:id])
  end

  def subscription_params
    params.require(:subscription).permit(:plan, :qty, :starts_at, :ends_at, :is_active)
  end

  def subscription_json(subscription)
    {
      id: subscription.id,
      plan: subscription.plan,
      qty: subscription.qty,
      starts_at: subscription.starts_at,
      ends_at: subscription.ends_at,
      is_active: subscription.is_active,
      active: subscription.active?,
      expired: subscription.expired?,
      pending: subscription.pending?,
      created_at: subscription.created_at
    }
  end
end