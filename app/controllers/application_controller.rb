class ApplicationController < ActionController::API
  rescue_from TokenService::TokenGenerationError, with: :handle_token_generation_error
  rescue_from TokenService::VerificationError, with: :handle_verification_error
  rescue_from TokenService::ExpiredTokenError, with: :handle_expired_token_error
  rescue_from TokenService::DecodeError, with: :handle_decode_error

  private

  def authorize_with_jwt!
    auth_header = request.headers['Authorization']

    token = auth_header.split(' ')[1]

    TokenService.decode_token(token)
  end

  def render_success_response(message:, data:, status:)
    render json: { status: 'success', message: message, data: data }, status: status
  end

  def render_error_response(message:, data:, status:)
    render json: { status: 'error', message: message, data: data }, status: status
  end

  def handle_token_generation_error(e)
    render_error_response(message: 'Token generation failed!', data: e.message, status: :internal_server_error)
  end

  def handle_verification_error(e)
    render_error_response(message: 'Token signature verification failed', data: e.message, status: :unauthorized)
  end

  def handle_expired_token_error(e)
    render_error_response(message: 'Access token has expired', data: e.message, status: :unauthorized)
  end

  def handle_decode_error(e)
    render_error_response(message: 'Invalid token', data: e.message, status: :unauthorized)
  end
end
