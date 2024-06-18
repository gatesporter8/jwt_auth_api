require 'rails_helper'

RSpec.describe TokenService do
  let(:user) { FactoryBot.create(:user) }
  let(:test_secret) { 'test_secret' }

  before do
    allow(ENV).to receive(:[]).with('JWT_SECRET').and_return(test_secret)
  end

  describe '.generate_tokens' do
    context 'when tokens are successfully generated' do
      it 'returns a JWT and a refresh token' do
        jwt, refresh_token = described_class.generate_tokens(user)
        decoded_jwt = JWT.decode(jwt, test_secret).first

        expect(decoded_jwt['user_id']).to eq(user.id)
        found_refresh_token = RefreshToken.find_by_user_id(user.id)
        expect(found_refresh_token.token).to eq(refresh_token)
      end
    end

    context 'when there is an error generating tokens' do
      before do
        allow(JWT).to receive(:encode).and_raise(StandardError.new('fake error'))
      end

      it 'raises a TokenServiceTokenGenerationError' do
        expect { described_class.generate_tokens(user) }.to raise_error(TokenService::TokenGenerationError)
      end
    end
  end

  describe '.decode_token' do
    let(:jwt) { JWT.encode({ user_id: user.id, exp: 10.minutes.from_now.to_i }, test_secret) }

    context 'when the token is valid' do
      it 'returns the user ID' do
        expect(described_class.decode_token(jwt)).to eq(user.id)
      end
    end

    context 'when the token has expired' do
      let(:expired_jwt) { JWT.encode({ user_id: user.id, exp: 5.minutes.ago.to_i }, test_secret) }

      it 'raises a TokenServiceExpiredTokenError' do
        expect { described_class.decode_token(expired_jwt) }.to raise_error(TokenService::ExpiredTokenError)
      end
    end

    context 'when the token has an invalid signature' do
      let(:invalid_jwt) { JWT.encode({ user_id: user.id }, 'wrong_secret') }

      it 'raises a TokenServiceVerificationError' do
        expect { described_class.decode_token(invalid_jwt) }.to raise_error(TokenService::VerificationError)
      end
    end

    context 'when the token is malformed' do
      it 'raises a TokenServiceDecodeError' do
        expect { described_class.decode_token('malformed.token') }.to raise_error(TokenService::DecodeError)
      end
    end
  end
end
