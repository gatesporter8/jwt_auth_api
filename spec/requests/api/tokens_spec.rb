require 'swagger_helper'

describe 'Token Validation API' do

  path '/api/token/validate' do

    post 'Validates a token' do
      tags 'Tokens'
      consumes 'application/json'
      produces 'application/json'
      parameter name: 'Authorization', in: :header, type: :string, required: true, description: 'Authorization header with Bearer token'

      response '200', 'token is valid' do
        let(:Authorization) { 'Bearer valid_token' }

        before do
          allow(TokenService).to receive(:decode_token).with('valid_token').and_return(true)
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq('success')
          expect(data['message']).to eq('Token is valid')
        end

        examples 'application/json' => {
          response: {
            status: 'success',
            message: 'Token is valid',
            data: {}
          }
        }
      end

      response '401', 'Token signature verification failed' do
        let(:Authorization) { 'Bearer invalid_token' }

        before do
          allow(TokenService).to receive(:decode_token).with('invalid_token').and_raise(TokenService::VerificationError, 'Token signature verification failed')
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq('error')
          expect(data['message']).to eq('Token signature verification failed')
        end

        examples 'application/json' => {
          response: {
            status: 'error',
            message: 'Token signature verification failed',
            data: 'Token signature verification failed'
          }
        }
      end

      response '401', 'Access token has expired' do
        let(:Authorization) { 'Bearer expired_token' }

        before do
          allow(TokenService).to receive(:decode_token).with('expired_token').and_raise(TokenService::ExpiredTokenError, 'Access token has expired')
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq('error')
          expect(data['message']).to eq('Access token has expired')
        end

        examples 'application/json' => {
          response: {
            status: 'error',
            message: 'Access token has expired',
            data: 'Access token has expired'
          }
        }
      end

      response '401', 'Invalid token' do
        let(:Authorization) { 'Bearer invalid_format_token' }

        before do
          allow(TokenService).to receive(:decode_token).with('invalid_format_token').and_raise(TokenService::DecodeError, 'Error decoding token')
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']). to eq('error')
          expect(data['message']). to eq('Invalid token')
        end

        examples 'application/json' => {
          response: {
            status: 'error',
            message: 'Invalid token',
            data: 'Error decoding token'
          }
        }
      end
    end
  end

  path '/api/token/refresh' do
    post 'Refreshes a token' do
      tags 'Tokens'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :refresh_params, in: :body, schema: {
        type: :object,
        properties: {
          refresh_token: { type: :string }
        },
        required: [ 'refresh_token' ]
      }

      response '200', 'Token refreshed successfully' do
        let(:refresh_params) do
          {
            refresh_token: refresh_token
          }
        end
        let(:refresh_token) { 'valid_refresh_token' }
        let(:user) { create(:user) }
        let(:refresh_token_record) { create(:refresh_token, token: refresh_token, user: user, revoked: false, expires_at: 1.day.from_now) }

        before do
          allow(RefreshToken).to receive(:find_by).with(token: 'valid_refresh_token').and_return(refresh_token_record)
          allow(TokenService).to receive(:generate_tokens).with(user).and_return(['new_jwt', 'new_refresh_token'])
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq('success')
          expect(data['message']).to eq('Token refreshed successfully')
          expect(data['data']['jwt']).to eq('new_jwt')
          expect(data['data']['refresh_token']).to eq('new_refresh_token')
        end

        examples 'application/json' => {
          response: {
            status: 'success',
            message: 'Token refreshed successfully',
            data: {
              jwt: 'new_jwt',
              refresh_token: 'new_refresh_token'
            }
          }
        }
      end

      response '401', 'Invalid refresh token' do
        let(:refresh_params) do
          {
            refresh_token: refresh_token
          }
        end
        let(:refresh_token) { 'invalid_refresh_token' }

        before do
          allow(RefreshToken).to receive(:find_by).with(token: 'invalid_refresh_token').and_return(nil)
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq('error')
          expect(data['message']).to eq('Invalid refresh token')
        end

        examples 'application/json' => {
          response: {
            status: 'error',
            message: 'Invalid refresh token',
            data: nil
          }
        }
      end

      response '401', 'Refresh token has been revoked' do
        let(:refresh_params) do
          {
            refresh_token: refresh_token
          }
        end
        let(:refresh_token) { 'revoked_refresh_token' }
        let(:user) { create(:user) }
        let(:refresh_token_record) { create(:refresh_token, token: refresh_token, user: user, revoked: true, expires_at: 1.day.from_now) }

        before do
          allow(RefreshToken).to receive(:find_by).with(token: 'revoked_refresh_token').and_return(refresh_token_record)
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq('error')
          expect(data['message']).to eq('Refresh token has been revoked')
        end

        examples 'application/json' => {
          response: {
            status: 'error',
            message: 'Refresh token has been revoked',
            data: nil
          }
        }
      end

      response '401', 'Refresh token has expired' do
        let(:refresh_params) do
          {
            refresh_token: refresh_token
          }
        end
        let(:refresh_token) { 'expired_refresh_token' }
        let(:user) { create(:user) }
        let(:refresh_token_record) { create(:refresh_token, token: refresh_token, user: user, revoked: false, expires_at: 1.day.ago) }

        before do
          allow(RefreshToken).to receive(:find_by).with(token: 'expired_refresh_token').and_return(refresh_token_record)
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq('error')
          expect(data['message']).to eq('Refresh token has expired')
        end

        examples 'application/json' => {
          response: {
            status: 'error',
            message: 'Refresh token has expired',
            data: nil
          }
        }
      end
    end
  end
end