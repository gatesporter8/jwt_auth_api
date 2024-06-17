class TokenService
  def self.generate_tokens(user_id)
    # generate JWT
    jwt = JWT.encode({ user_id: user_id}, ENV['JWT_SECRET'])
    # generate refresh token
    refresh_token = SecureRandom.hex(16)
    # return both tokens
  end
end