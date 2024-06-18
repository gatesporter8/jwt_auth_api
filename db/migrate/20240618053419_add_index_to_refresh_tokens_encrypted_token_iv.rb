class AddIndexToRefreshTokensEncryptedTokenIv < ActiveRecord::Migration[7.0]
  def change
    add_index :refresh_tokens, :encrypted_token_iv, unique: true
  end
end
