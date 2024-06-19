class RefreshToken < ApplicationRecord
  # encrypt the refresh token before saving it to the database in case an attacker gains access to the database
  has_encrypted :token
  blind_index :token, slow: true
  before_validation :generate_token, on: :create
  before_create :revoke_active_tokens

  belongs_to :user

  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true
  validates :revoked, inclusion: { in: [true, false] }

  private

  def generate_token
    self.token = SecureRandom.hex(20)
  end

  # only one active token at a time per user
  def revoke_active_tokens
    user.refresh_tokens.where(revoked: false).update_all(revoked: true)
  end
end
