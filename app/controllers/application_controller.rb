class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :authenticate, except: :unknown_route

  def authenticate
    auth = AuthenticationService.new(request: request, params: params)
    if auth.authenticate_with_jwt
      @current_org = auth.current_org
      @current_user = auth.current_user
    else
      return render_unauthorized
    end
  end

  def current_user
    @current_user
  end
 
  def current_org
    @current_org
  end

  def render_unauthorized(message = nil)
    render_with_status_and_message(message, status: :unauthorized)
  end

  def render_unprocessable_entity(message = nil)
    render_with_status_and_message(message, status: :unprocessable_entity)
  end

  def render_bad_request(message = nil)
    render_with_status_and_message(message, status: :bad_request)
  end

  def render_not_found(message = nil)
    render_with_status_and_message(message, status: :not_found)
  end

  def render_with_status_and_message(message = nil , status:)
    if message
      render json: {message: message}, status: status
    else
      render json: :no_content, status: status
    end
  end
end
