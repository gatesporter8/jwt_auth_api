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
end