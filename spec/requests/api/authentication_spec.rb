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

        examples 'application/json' => {
          request: {
            user: {
              email: 'newuser@example.com',
              password: 'password123'
            }
          },
          response: {
            status: 'success',
            message: 'Registration successful!',
            data: {
              jwt: 'generated_jwt_token',
              refresh_token: 'generated_refresh_token'
            }
          }
        }
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
          expect(data['message']). to include('Registration failed!')
        end

        examples 'application/json' => {
          request: {
            user: {
              email: '',
              password: 'password123'
            }
          },
          response: {
            status: 'error',
            message: 'Registration failed!',
            data: {
              email: ["can't be blank"]
            }
          }
        }
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

        before { allow(TokenService).to receive(:generate_tokens).and_raise(TokenService::TokenGenerationError) }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq('error')
          expect(data['message']). to include('Token generation failed!')
        end
        
        examples 'application/json' => {
          request: {
            user: {
              email: 'newuser@example.com',
              password: 'password123'
            }
          },
          response: {
            status: 'error',
            message: 'Token generation failed!',
            data: 'Detailed error message'
          }
        }
      end
    end
  end

  path '/api/login' do

    post 'Logs in a user' do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :login_params, in: :body, schema: {
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
      }, required: true, description: 'User login parameters'

      response '200', 'login successful' do
        let!(:user) { create(:user, email: 'existinguser@example.com', password: 'password123') }
        let(:login_params) do 
          { 
            user: {
              email: 'existinguser@example.com', 
              password: 'password123' 
            } 
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq('success')
          expect(data['message']). to eq('Login successful!')
          expect(data['data']).to have_key('jwt')
          expect(data['data']).to have_key('refresh_token')
        end

        examples 'application/json' => {
          request: {
            user: {
              email: 'existinguser@example.com',
              password: 'password123'
            }
          },
          response: {
            status: 'success',
            message: 'Login successful!',
            data: {
              jwt: 'generated_jwt_token',
              refresh_token: 'generated_refresh_token'
            }
          }
        }
      end

      response '404', 'user not found' do
        let(:login_params) do 
          { 
            user: {
              email: 'nonexistent@example.com', 
              password: 'password123' 
            } 
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq('error')
          expect(data['message']). to include('User with email nonexistent@example.com not found!')
        end

        examples 'application/json' => {
          request: {
            user: {
              email: 'nonexistent@example.com',
              password: 'password123'
            }
          },
          response: {
            status: 'error',
            message: 'User with email nonexistent@example.com not found!',
            data: nil
          }
        }
      end

      response '401', 'invalid password' do
        let!(:user) { create(:user, email: 'existinguser@example.com', password: 'password123') }
        let(:login_params) do 
          { 
            user: {
              email: 'existinguser@example.com', 
              password: 'wrongpassword' 
            } 
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq('error')
          expect(data['message']). to include('Login failed! Invalid password')
        end

        examples 'application/json' => {
          request: {
            user: {
              email: 'existinguser@example.com',
              password: 'wrongpassword'
            }
          },
          response: {
            status: 'error',
            message: 'Login failed! Invalid password',
            data: nil
          }
        }
      end

      response '500', 'token generation failed' do
        let!(:user) { create(:user, email: 'existinguser@example.com', password: 'password123') }
        let(:login_params) do 
          { 
            user: {
              email: 'existinguser@example.com', 
              password: 'password123' 
            } 
          }
        end

        before { allow(TokenService).to receive(:generate_tokens).and_raise(TokenService::TokenGenerationError) }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['status']).to eq('error')
          expect(data['message']). to include('Token generation failed!')
        end
        
        examples 'application/json' => {
          request: {
            user: {
              email: 'existinguser@example.com',
              password: 'password123'
            }
          },
          response: {
            status: 'error',
            message: 'Token generation failed!',
            data: 'Detailed error message'
          }
        }
      end
    end
  end
end