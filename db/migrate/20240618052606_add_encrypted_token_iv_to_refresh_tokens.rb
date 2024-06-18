class AddEncryptedTokenIvToRefreshTokens < ActiveRecord::Migration[7.0]
  def change
    add_column :refresh_tokens, :encrypted_token_iv, :string
  end
end
