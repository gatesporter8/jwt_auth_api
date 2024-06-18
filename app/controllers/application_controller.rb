class ApplicationController < ActionController::API
  rescue_from TokenService::TokenServiceTokenGenerationError, with: :handle_token_generation_error

  private

  def render_success_response(message:, data:, status:)
    render json: { status: 'success', message: message, data: data }, status: status
  end

  def render_error_response(message:, data:, status:)
    render json: { status: 'error', message: message, data: data }, status: status
  end

  def handle_token_generation_error(e)
    render_error_response(message: 'Token generation failed!', data: e.message, status: :internal_server_error)
  end
end
