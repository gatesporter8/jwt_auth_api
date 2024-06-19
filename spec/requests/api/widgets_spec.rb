require 'swagger_helper'

describe 'Widgets API' do

  path '/api/widgets' do

    get 'Retrieves a list of widgets' do
      tags 'Widgets'
      consumes 'application/json'
      produces 'application/json'
      parameter name: 'Authorization', in: :header, type: :string, required: true, description: 'Authorization header with Bearer token'

      response '200', 'widgets retrieved successfully' do
        let(:Authorization) { 'Bearer valid_token' }

        before do
          allow(TokenService).to receive(:decode_token).with('valid_token').and_return(true)
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq('success')
          expect(data['message']).to eq('Here is a list of widgets!')
          expect(data['data']).to eq([
            { "id" => 1, "name" => "Foo" },
            { "id" => 2, "name" => "Bar" },
            { "id" => 3, "name" => "Baz" }
          ])
        end

        examples 'application/json' => {
          response: {
            status: 'success',
            message: 'Here is a list of widgets!',
            data: [
              { "id": 1, "name": "Foo" },
              { "id": 2, "name": "Bar" },
              { "id": 3, "name": "Baz" }
            ]
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