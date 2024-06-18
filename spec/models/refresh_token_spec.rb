require 'rails_helper'

RSpec.describe RefreshToken, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it 'validates presence of token' do
      refresh_token1 = create(:refresh_token)
      refresh_token2 = create(:refresh_token)
      refresh_token2.token = nil

      refresh_token2.valid?
      expect(refresh_token2.errors[:token]).to include("can't be blank")
    end

    it 'validates uniqueness of token' do
      refresh_token1 = create(:refresh_token)
      refresh_token2 = create(:refresh_token)
      refresh_token2.token = refresh_token1.token

      refresh_token2.valid?
      expect(refresh_token2.errors[:token]).to include("has already been taken")
    end

    it { should validate_presence_of(:expires_at) }
    it { should validate_inclusion_of(:revoked).in_array([true, false]) }
  end

  describe 'callbacks' do
    it 'should generate a token before validating a new refresh token' do
      refresh_token = build(:refresh_token, token: nil)
      refresh_token.valid?
      expect(refresh_token.token).to be_present
    end
  end
end
