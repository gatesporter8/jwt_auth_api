class Api::TokensController < ApplicationController
  def validate
    auth_header = request.headers['Authorization']

    token = auth_header.split(' ')[1]

    TokenService.decode_token(token)

    render_success_response(message: 'Token is valid', data: {}, status: :ok)
  rescue TokenService::VerificationError => e
    render_error_response(message: 'Token signature verification failed', data: e.message, status: :unauthorized)
  rescue TokenService::ExpiredTokenError => e
    render_error_response(message: 'Access token has expired', data: e.message, status: :unauthorized)
  rescue TokenService::DecodeError => e
    render_error_response(message: 'Invalid token', data: e.message, status: :unauthorized)
  end
end
