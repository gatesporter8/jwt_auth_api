class Api::AuthenticationController < ApplicationController
  def register
    user = User.new(user_params)
    if user.save
      # create new JWT and refresh token
      render json: { status: 'success', message: 'Registration successful!', data: user }, status: :created
    else
      render json: { status: 'error', message: 'Registration failed!', data: user.errors }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end
end
