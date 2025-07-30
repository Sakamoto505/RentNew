class ApplicationController < ActionController::API
  include Pagy::Backend
  before_action :configure_permitted_parameters, if: :devise_controller?

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :role,
      :company_name
    ])

    devise_parameter_sanitizer.permit(:account_update, keys: [
      :role,
      :company_name

    ])
  end
end
