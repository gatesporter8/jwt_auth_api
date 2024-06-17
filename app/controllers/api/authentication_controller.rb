class Api::AuthenticationController < ApplicationController
  def register
    user = User.new(user_params)
    if user.save
      jwt, refresh_token = TokenService.generate_tokens(user)

      response_data = { jwt:, refresh_token:}

      # NOTE: if this were being used by a browser, we would want to set a secure cookie here for the refresh token
      render json: { status: 'success', message: 'Registration successful!', data: response_data }, status: :created
    else
      render json: { status: 'error', message: 'Registration failed!', data: user.errors }, status: :unprocessable_entity
    end
  rescue TokenService::TokenServiceTokenGenerationError => e
    render json: { status: 'error', message: 'Token generation failed!', data: e.message }, status: :internal_server_error
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end
end
