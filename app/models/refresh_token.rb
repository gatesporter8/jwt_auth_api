class RefreshToken < ApplicationRecord
  # encrypt the refresh token before saving it to the database in case an attacker gains access to the database
  has_encrypted :token
  blind_index :token, slow: true
  before_validation :generate_token, on: :create

  belongs_to :user

  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true
  validates :revoked, inclusion: { in: [true, false] }

  private

  def generate_token
    self.token = SecureRandom.hex(20)
  end
end
