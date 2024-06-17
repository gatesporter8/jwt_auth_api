class TokenService
  JWT_EXPIRATION_TIME = 10.minutes
  REFRESH_TOKEN_EXPIRATION_TIME = 15.days

  class TokenServiceDecodeError < StandardError; end
  class TokenServiceExpiredTokenError < StandardError; end
  class TokenServiceVerificationError < StandardError; end
  class TokenServiceTokenGenerationError < StandardError; end

  def self.generate_tokens(user)
    jwt = generate_jwt(user)
    refresh_token = generate_refresh_token(user)

    return jwt, refresh_token
  rescue StandardError => e
    Rails.logger.error("Error generating tokens: #{e.message}")
    raise TokenServiceTokenGenerationError, "Error generating tokens!"
  end

  def self.decode_token(token)
    decoded_token = JWT.decode(token, ENV['JWT_SECRET'])
    decoded_token[0]['user_id']
  rescue JWT::VerificationError => e
    Rails.logger.error("JWT verification failed: #{e.message}")
    raise TokenServiceVerificationError, "Verification failed for access token!"
  rescue JWT::ExpiredSignature => e
    Rails.logger.error("Access token has expired: #{e.message}")
    raise TokenServiceExpiredTokenError, "Access token has expired!"
  rescue JWT::DecodeError => e
    Rails.logger.error("Error decoding token: #{e.message}")
    raise TokenServiceDecodeError, "Error decoding token!"
  end

  private

  def self.generate_jwt(user)
    JWT.encode({ user_id: user.id, exp: JWT_EXPIRATION_TIME.from_now.to_i }, ENV['JWT_SECRET'])
  end

  def self.generate_refresh_token(user)
    refresh_token_record = RefreshToken.create(user: user, expires_at: REFRESH_TOKEN_EXPIRATION_TIME.from_now)
    refresh_token_record.token
  end
end