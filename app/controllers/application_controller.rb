
class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid

  private

  def authenticate_user!
    header = request.headers["Authorization"]
    token = header&.match(/\ABearer\s+(.+)\z/i)&.captures&.first

    unless token
      render json: { error: "Authentication token required" },
             status: :unauthorized
      return
    end

    decoded_token = JWT.decode(
      token,
      Rails.application.secret_key_base,
      true,
      algorithm: "HS256"
    )

    user_id = decoded_token.first["user_id"]
    @current_user = User.find(user_id)

  rescue JWT::DecodeError, JWT::ExpiredSignature
    render json: { error: "Invalid or expired token" },
           status: :unauthorized
  end

  def current_user
    @current_user
  end

  def record_not_found(error)
    render json: {
      error: "Record not found",
      message: error.message
    }, status: :not_found
  end

  def record_invalid(error)
    render json: {
      error: "Validation failed",
      messages: error.record.errors.full_messages
    }, status: :unprocessable_entity
  end
end
