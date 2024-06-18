class RefreshToken < ApplicationRecord
  # encrypt the refresh token before saving it to the database in case an attacker gains access to the database
  attr_encrypted :token, key: [ENV['REFRESH_TOKEN_ENCRYPTION_KEY']].pack('H*')
  before_validation :generate_token, on: :create

  belongs_to :user

  validates :encrypted_token, presence: true
  validates :expires_at, presence: true
  validates :revoked, inclusion: { in: [true, false] }

  private

  def generate_token
    self.token = SecureRandom.hex(20)
  end
end
