# JWT-based Authentication API with Token Refresh

I built this using Rails' API-only mode, since I've had a lot of experience building similar JWT authenticated API's with Rails' api only mode in previous roles, such as Search Service at Linksquares.

## Database and Security

I'm using PostgreSQL to manage the users and refresh_tokens tables in my application. Given the sensitive nature of refresh tokens, which can authorize access for extended periods, it's crucial to secure them. I employ the [Lockbox gem](https://github.com/ankane/lockbox) for encryption and the [Blind Index gem](https://github.com/ankane/blind_index) for secure, searchable indexing. Encrypting refresh tokens before storing them in the database is essential to protect against unauthorized access in the event of a security breach.

## Token Management

I'm using the [jwt gem](https://github.com/jwt/ruby-jwt), a popular library for encoding and decoding JWTs. I'm encapsulating all behavior from this gem in a service class called `TokenService`, which encodes/decodes tokens, and handles errors from the JWT gem by bubbling up its own `TokenService` errors that it defines. In a real app, this class could be fleshed out with more customized behavior and could function as the single source of truth for everything related to encoding and decoding JWTs.

The `TokenService` class sets the expiration time of the JWT access tokens to **10 minutes**, a short enough time that it reflects the short expiration periods JWTs typically have in the real world, but also long enough so we can play around with the functionality of the app without having to frequently hit the /api/refresh endpoint. 

For the refresh tokens, it sets the expiration time to **15 days**, which reflects the longer expiration periods that refresh tokens have, allowing the user to request a new access token without having to login. Because of these longer expiration times, it is crucial that every effort is taken to keep refresh tokens secure, which I do by including the revoked column, encrypting the tokens when they are saved to Postgres, and not logging the tokens.

## API Design

My controllers define a standard response structure for both error and success responses for the user of the API via methods that are defined in the ApplicationController.

## Testing

I’m using Rspec, FactoryBot, and faker for my unit + request test suite. I’m also using [shoulda-matchers](https://github.com/thoughtbot/shoulda-matchers) for testing my models, since this gem simplifies the testing of validations and associations. 

## Documentation

Since this is an API, I’m also using the [rswag gem](https://github.com/rswag/rswag) for my request specs, which generates API documentation via `rake rswag:specs:swaggerize` that can be viewed at the `/api-docs` endpoint.

<img width="1434" alt="Screenshot 2024-06-18 at 10 51 00 PM" src="https://github.com/gatesporter8/jwt_auth_api/assets/7433935/0a769223-b546-47e3-9361-0d89f6d84aa1">

## Running the App

1. Install all gems with `bundle install`.
2. Run the server with `rails s`.
3. You can hit the API with whatever tooling you want - I use [Postman](https://www.postman.com/).

## Important Notes

1. If this were a production application, we would not want to commit the .env file with the secret keys to version control, and we would want to have some sort of secret manager (like AWS secrets manager) for storing the keys for our staging and production environments. It’s very important to take serious precautions when keeping your JWT secrets, and encryption keys safe.
2. If this API were being used by a web browser, we would want to transfer the refresh token to and from the user in a secure HTTP cookie, instead of in the request and response body. Refresh tokens are particularly sensitive because they allow users to obtain new access tokens, potentially for a prolonged period. If a refresh token is compromised, an attacker could gain prolonged access to the user's account. Therefore, transferring refresh tokens securely is paramount. Transferring tokens in a secure cookie prevents them from being accessed by client-side scripts and thus reduces the risk of them being exposed via cross-site scripting (XSS) attacks. For the purposes of an API however in a production app, we would want to configure our infrastructure to make sure our API only serves traffic over HTTPS.



