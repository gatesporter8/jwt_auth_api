class Api::AuthenticationController < ApplicationController
  def register
    user = User.new(user_params)
    if user.save
      jwt, refresh_token = TokenService.generate_tokens(user)

      # NOTE: 
      # If this application were interacting with a web browser, 
      # we would want to store the refresh token in a secure HTTP cookie.
      response_data = { jwt:, refresh_token:}

      render_success_response(message: 'Registration successful!', data: response_data, status: :created)
    else
      render_error_response(message: 'Registration failed!', data: user.errors, status: :unprocessable_entity)
    end
  end

  def login
    user = User.find_by(email: user_params[:email])

    unless user
      return render_error_response(
        message: "User with email #{user_params[:email]} not found!", 
        data: nil, 
        status: :not_found
      )
    end
    
    if user.authenticate(user_params[:password])
      jwt, refresh_token = TokenService.generate_tokens(user)

      response_data = { jwt: jwt, refresh_token: refresh_token }

      render_success_response(message: 'Login successful!', data: response_data, status: :ok)
    else
      render_error_response(message: 'Login failed! Invalid password', data: nil, status: :unauthorized)
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end
end