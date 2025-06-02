class Users::SessionsController < Devise::SessionsController
  include RackSessionFix

  respond_to :json

  def new
    render json: {
      status: {code: 200, message: 'Login page'},
      data: {
        login_url: '/login',
        signup_url: '/signup'
      }
    }, status: :ok
  end

  private

  def respond_with(resource, _opts = {})
    render json: {
      status: {code: 200, message: 'Logged in sucessfully.'},
      data: UserSerializer.new(resource).serializable_hash[:data][:attributes]
    }, status: :ok
  end

  def respond_to_on_destroy
    if current_user
      render json: {
        status: 200,
        message: "logged out successfully"
      }, status: :ok
    else
      render json: {
        status: 401,
        message: "Couldn't find an active session."
      }, status: :unauthorized
    end
  end
end