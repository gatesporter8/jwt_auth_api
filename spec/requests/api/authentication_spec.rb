require 'swagger_helper'

describe 'Authentication API' do

  path '/api/register' do

    post 'Registers a new user' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :registration_params, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, example: 'user@example.com' },
              password: { type: :string, example: 'password' }
            },
            required: ['email', 'password']
          }
        }
      }, required: true, description: 'User registration parameters'

      response '201', 'registration successful' do
        let(:registration_params) do 
          { 
            user: {
              email: 'newuser@example.com', 
              password: 'password123' 
            } 
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq('success')
          expect(data['message']).to eq('Registration successful!')
          expect(data['data']).to have_key('jwt')
          expect(data['data']).to have_key('refresh_token')
        end
      end

      response '422', 'registration failed' do
        let(:registration_params) do 
          { 
            user: {
              email: '', 
              password: 'password123' 
            } 
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq('error')
          expect(data['message']).to include('Registration failed!')
        end
      end

      response '500', 'token generation failed' do
        let(:registration_params) do 
          { 
            user: {
              email: 'newuser@example.com', 
              password: 'password123' 
            } 
          }
        end

        before { allow(TokenService).to receive(:generate_tokens).and_raise(TokenService::TokenServiceTokenGenerationError) }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq('error')
          expect(data['message']).to include('Token generation failed!')
        end
      end
    end
  end
end