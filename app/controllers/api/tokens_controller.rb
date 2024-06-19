class Api::TokensController < ApplicationController
  before_action :authorize_with_jwt!, only: [:validate]

  def validate
    render_success_response(message: 'Token is valid', data: {}, status: :ok)
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

    if refresh_token_record.expires_at < Time.current
      return render_error_response(message: 'Refresh token has expired. You must login again.', data: nil, status: :unauthorized)
    end

    jwt, new_refresh_token = TokenService.generate_tokens(refresh_token_record.user)

    response_data = { jwt:, refresh_token: new_refresh_token }

    render_success_response(message: 'Token refreshed successfully', data: response_data, status: :ok)
  end
end
