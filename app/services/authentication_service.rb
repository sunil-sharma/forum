class AuthenticationService
  attr_accessor :params, :current_org, :current_user, :jwt_payload, :jwt_header, :current_course
  def initialize(request: {}, params: {})
    @params          = params
    @request         = request
    @auth_token      = @request.headers['X-API-AUTH-TOKEN'] || params["auth_token"]
  end

  def authenticate_with_jwt
    begin
      @jwt_payload, @jwt_header = JWT.decode(@auth_token, Settings.savannah_token)
      if @jwt_payload
        @current_org = organization
        @current_user = get_or_create_user if @current_org && @jwt_payload["user_email"]
      end
    rescue => e
      ##TODO add bugsnag
      puts "Authentication failed due to this exception: #{e}"
    end
  end

  def organization
    Organization.find_by(savannah_app_id: @jwt_payload["savannah_app_id"]) if @jwt_payload["savannah_app_id"]
  end

  def get_or_create_user
    User.find_or_create_by(email: @jwt_payload["user_email"], organization_id: @current_org.id) do |user|
      user.first_name = @jwt_payload["first_name"]
      user.last_name = @jwt_payload["last_name"]
      user.password = SecureRandom.hex
      user.is_complete = true
      user.password_reset_required = false
      user.organization_role = 'member'
    end
  end

  def current_course
    @organization.resource_groups.find_by(client_resource_id: @jwt_payload["resource_id"])
  end
end
