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

  def refresh
    refresh_token = params[:refresh_token]

    refresh_token_record = RefreshToken.find_by(token: refresh_token)

    if refresh_token_record.nil?
      return render_error_response(message: 'Invalid refresh token', data: nil, status: :unauthorized)
    end

    if refresh_token_record.revoked
      return render_error_response(message: 'Refresh token has been revoked', data: nil, status: :unauthorized)
    end

    if refresh_token_record.expires_at < Time.now
      return render_error_response(message: 'Refresh token has expired', data: nil, status: :unauthorized)
    end

    refresh_token_record.update(revoked: true)

    jwt, new_refresh_token = TokenService.generate_tokens(refresh_token_record.user)

    response_data = { jwt:, refresh_token: new_refresh_token }

    render_success_response(message: 'Token refreshed successfully', data: response_data, status: :ok)
  end
end
